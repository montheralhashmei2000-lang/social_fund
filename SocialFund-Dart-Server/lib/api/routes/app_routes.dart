import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../../db/database.dart';
import '../../db/repositories/journal_repository.dart';
import '../../services/report_service.dart';
import '../../services/voucher_pdf_service.dart';
import '../middleware.dart';

/// مسارات يستدعيها تطبيق الجوال ولم تكن معرّفة في الخادم، فكانت تعيد 404:
/// اعتماد/رفض/صرف المساعدات، قراءة الرسائل، القيود اليدوية، التحقق من بطاقة
/// العضو، ملف المانح، رموز الإشعارات، النسخ الاحتياطي، وسند PDF.
class AppRoutes {
  final AppDatabase db;
  AppRoutes(this.db);

  /// الانتقالات المسموحة لحالة طلب المساعدة.
  static const Map<String, Set<String>> aidTransitions = {
    'قيد المراجعة': {'معتمدة', 'مرفوضة'},
    'معتمدة': {'مصروفة'},
    'مرفوضة': {},
    'مصروفة': {},
  };

  Router get router {
    final r = Router();

    // ---------- المساعدات: تغيير الحالة بانتقالات صحيحة فقط ----------
    r.patch('/aids/<id>/status', (Request req, String id) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final status = (b['status'] ?? '').toString().trim();
      if (!aidTransitions.containsKey(status)) return jsonErr(400, 'حالة غير صالحة');
      final aid = await (db.select(db.aidRequests)
            ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();
      if (aid == null) return jsonErr(404, 'الطلب غير موجود');
      if (!(aidTransitions[aid.status]?.contains(status) ?? false)) {
        return jsonErr(400, 'لا يمكن الانتقال من «${aid.status}» إلى «$status»');
      }
      final uid = req.context['userId'] as String?;
      final reviewer = uid == null ? null : await _userName(uid);
      await (db.update(db.aidRequests)..where((t) => t.id.equals(id))).write(
        AidRequestsCompanion(
          status: Value(status),
          reviewerId: Value(uid),
          reviewerName: Value(reviewer),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final updated = await (db.select(db.aidRequests)..where((t) => t.id.equals(id))).getSingle();
      return jsonOk({
        'id': updated.id, 'member_id': updated.memberId, 'member_name': updated.memberName,
        'aid_type': updated.aidType, 'amount': updated.amount,
        'request_date': updated.requestDate, 'status': updated.status,
        'note': updated.note, 'reviewer_name': updated.reviewerName,
        'currency': updated.currencyCode, 'original_amount': updated.originalAmount,
        'exchange_rate': updated.exchangeRate,
      });
    });

    // ---------- الرسائل: تعليم كمقروءة (للمستلم فقط) ----------
    r.patch('/messages/<id>/read', (Request req, String id) async {
      final uid = req.context['userId'] as String?;
      final n = await (db.update(db.messages)
            ..where((t) => t.id.equals(id) & t.toUserId.equals(uid ?? '')))
          .write(const MessagesCompanion(read: Value(true)));
      if (n == 0) return jsonErr(404, 'الرسالة غير موجودة');
      return jsonOk({'ok': true});
    });

    // ---------- قيد يومية يدوي متعدد الأسطر ----------
    r.post('/journal', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      try {
        final id = await JournalRepository(db).createManual(
          entryDate: (b['entry_date'] ?? '').toString().trim(),
          description: (b['description'] ?? '').toString().trim(),
          entryType: (b['entry_type'] ?? 'manual').toString(),
          lines: [
            for (final raw in (b['lines'] as List? ?? const []))
              ManualLine(
                accountId: ((raw as Map)['account_id'] ?? '').toString(),
                debit: (raw['debit'] as num?)?.toDouble() ?? 0,
                credit: (raw['credit'] as num?)?.toDouble() ?? 0,
              ),
          ],
          createdBy: req.context['userId'] as String?,
        );
        return jsonOk({'id': id});
      } on JournalException catch (e) {
        return jsonErr(400, e.message);
      }
    });

    // ---------- التحقق الميداني من بطاقة العضو ----------
    r.get('/members/<id>/card-verify', (Request req, String id) async {
      final m = await (db.select(db.members)
            ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();
      if (m == null) {
        return jsonOk({'verified': false, 'name': 'غير معروف', 'status': 'غير موجود',
          'total_paid': 0, 'balance_due': 0});
      }
      return jsonOk({
        'verified': m.status == 'نشط',
        'name': m.name,
        'status': m.status,
        'total_paid': m.totalPaid,
        'balance_due': m.balanceDue,
      });
    });

    // ---------- ملف المانح: تبرعاته (سندات القبض) ووعوده ----------
    r.get('/donors/<id>', (Request req, String id) async {
      final d = await (db.select(db.donors)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (d == null) return jsonErr(404, 'المانح غير موجود');
      final vouchers = await (db.select(db.vouchers)
            ..where((t) => t.donorId.equals(id) & t.deleted.equals(false) & t.status.equals('معتمد'))
            ..orderBy([(t) => OrderingTerm.desc(t.voucherDate)]))
          .get();
      final pledges = await (db.select(db.pledges)..where((t) => t.donorId.equals(id))).get();
      return jsonOk({
        'id': d.id, 'name': d.name, 'phone': d.phone, 'email': d.email, 'notes': d.notes,
        'donor_type': d.donorType, 'tier': d.tier, 'is_active': d.isActive,
        'total_donated': vouchers.fold<int>(0, (s, v) => s + v.amount),
        'donations': [
          for (final v in vouchers)
            {
              'id': v.id, 'description': v.description, 'entry_no': v.voucherNo,
              'entry_date': v.voucherDate, 'amount': v.amount,
              'currency': v.currencyCode, 'original_amount': v.originalAmount,
            },
        ],
        'pledges': [
          for (final pl in pledges)
            {
              'id': pl.id, 'amount': pl.amount, 'frequency': pl.frequency,
              'frequency_label': _frequencyLabel(pl.frequency),
              'start_date': pl.startDate, 'status': pl.status,
            },
        ],
      });
    });

    // ---------- تقارير PDF / Excel ----------
    r.get('/reports/<key>/<format>', (Request req, String key, String format) async {
      final svc = ReportService(db);
      final t = await svc.table(key);
      if (t == null) return jsonErr(404, 'تقرير غير معروف');
      try {
        if (format == 'pdf') {
          return Response.ok(await svc.pdf(t), headers: {
            'Content-Type': 'application/pdf',
            'Content-Disposition': 'attachment; filename="${key}_report.pdf"',
          });
        }
        if (format == 'excel' || format == 'xlsx') {
          return Response.ok(svc.xlsx(t), headers: {
            'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Content-Disposition': 'attachment; filename="${key}_report.xlsx"',
          });
        }
      } catch (e, st) {
        print('REPORT ERR: $e ' + st.toString());
        return jsonErr(500, 'تعذّر إنشاء التقرير');
      }
      return jsonErr(400, 'الصيغة pdf أو excel');
    });

    // ---------- مطابقة كشف البنك مع دفتر الأستاذ ----------
    r.get('/accounts/<id>/reconciliation', (Request req, String id) async {
      final acc = await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (acc == null) return jsonErr(404, 'الحساب غير موجود');
      final jl = await (db.select(db.journalLines)..where((t) => t.accountId.equals(id))).get();
      final ledger = jl.fold<double>(0, (s, l) => s + l.debit - l.credit);
      final lines = await (db.select(db.bankStatementLines)
            ..where((t) => t.accountId.equals(id))
            ..orderBy([(t) => OrderingTerm.desc(t.lineDate)]))
          .get();
      final stmt = lines.fold<double>(0, (s, l) => s + l.amount);
      return jsonOk({
        'account_id': id,
        'ledger_balance': ledger,
        'statement_sum': stmt,
        'difference': double.parse((ledger - stmt).toStringAsFixed(4)),
        'lines': [
          for (final l in lines)
            {
              'id': l.id, 'line_date': l.lineDate, 'description': l.description,
              'amount': l.amount, 'external_ref': l.externalRef, 'matched_line_id': l.matchedLineId,
            },
        ],
      });
    });

    // سطور القيود على الحساب التي لم تُطابَق بعد بسطر كشف.
    r.get('/accounts/<id>/unmatched-journal-lines', (Request req, String id) async {
      final matched = (await (db.select(db.bankStatementLines)
                ..where((t) => t.accountId.equals(id) & t.matchedLineId.isNotNull()))
              .get())
          .map((l) => l.matchedLineId!)
          .toSet();
      final jl = await (db.select(db.journalLines)..where((t) => t.accountId.equals(id))).get();
      final out = <Map<String, dynamic>>[];
      for (final l in jl) {
        if (matched.contains(l.id)) continue;
        final e = await (db.select(db.journalEntries)..where((t) => t.id.equals(l.entryId))).getSingleOrNull();
        out.add({
          'journal_line_id': l.id, 'entry_no': e?.entryNo ?? '-', 'entry_date': e?.entryDate ?? '',
          'description': e?.description ?? (l.memo ?? ''), 'debit': l.debit, 'credit': l.credit,
        });
      }
      out.sort((a, b) => '${b['entry_date']}'.compareTo('${a['entry_date']}'));
      return jsonOk(out);
    });

    r.post('/accounts/<id>/statement-lines', (Request req, String id) async {
      final acc = await (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (acc == null) return jsonErr(404, 'الحساب غير موجود');
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final date = (b['line_date'] ?? '').toString().trim();
      final desc = (b['description'] ?? '').toString().trim();
      final amount = (b['amount'] as num?)?.toDouble() ?? 0;
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) || desc.isEmpty || amount == 0) {
        return jsonErr(400, 'التاريخ (YYYY-MM-DD) والوصف ومبلغ غير صفري مطلوبة');
      }
      await db.into(db.bankStatementLines).insert(BankStatementLinesCompanion.insert(
        id: const Uuid().v4(), accountId: id, lineDate: date, description: desc, amount: amount,
        externalRef: Value((b['external_ref'] as String?)?.trim().isEmpty == true ? null : b['external_ref'] as String?),
        createdBy: Value(req.context['userId'] as String?), createdAt: DateTime.now(),
      ));
      return jsonOk({'ok': true});
    });

    r.post('/accounts/<id>/statement-lines/<lineId>/match', (Request req, String id, String lineId) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final jlId = (b['journal_line_id'] ?? '').toString();
      final line = await (db.select(db.bankStatementLines)
            ..where((t) => t.id.equals(lineId) & t.accountId.equals(id)))
          .getSingleOrNull();
      if (line == null) return jsonErr(404, 'سطر الكشف غير موجود');
      if (line.matchedLineId != null) return jsonErr(400, 'السطر مطابَق مسبقاً');
      final jl = await (db.select(db.journalLines)
            ..where((t) => t.id.equals(jlId) & t.accountId.equals(id)))
          .getSingleOrNull();
      if (jl == null) return jsonErr(404, 'سطر القيد غير موجود على هذا الحساب');
      final taken = await (db.select(db.bankStatementLines)..where((t) => t.matchedLineId.equals(jlId))).get();
      if (taken.isNotEmpty) return jsonErr(400, 'سطر القيد مطابَق مع سطر آخر');
      await (db.update(db.bankStatementLines)..where((t) => t.id.equals(lineId)))
          .write(BankStatementLinesCompanion(matchedLineId: Value(jlId)));
      return jsonOk({'ok': true});
    });

    // ---------- شهادة شكر المانح (PDF) ----------
    r.get('/donors/<id>/certificate', (Request req, String id) async {
      final d = await (db.select(db.donors)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (d == null) return jsonErr(404, 'المانح غير موجود');
      final receipts = await (db.select(db.vouchers)
            ..where((t) => t.donorId.equals(id) & t.deleted.equals(false) & t.status.equals('معتمد')))
          .get();
      try {
        final bytes = await VoucherPdfService.buildDonorCertificate(
            d, receipts.fold<int>(0, (s, v) => s + v.amount));
        return Response.ok(bytes, headers: {
          'Content-Type': 'application/pdf',
          'Content-Disposition': 'inline; filename="certificate.pdf"',
        });
      } catch (e) {
        print('CERT ERR: $e');
        return jsonErr(500, 'تعذّر إنشاء الشهادة');
      }
    });

    // ---------- رموز الإشعارات ----------
    r.post('/push/register-token', (Request req) async {
      final uid = req.context['userId'] as String?;
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final token = (b['token'] ?? '').toString();
      if (uid == null || token.isEmpty) return jsonErr(400, 'token required');
      final now = DateTime.now();
      final existing = await (db.select(db.deviceTokens)..where((t) => t.token.equals(token))).getSingleOrNull();
      if (existing == null) {
        await db.into(db.deviceTokens).insert(DeviceTokensCompanion.insert(
          id: const Uuid().v4(), userId: uid, token: token,
          platform: Value(b['platform'] as String?), createdAt: now, lastUsedAt: now,
        ));
      } else {
        // الجهاز انتقل لمستخدم آخر: يُعاد ربط الرمز بالمستخدم الحالي
        await (db.update(db.deviceTokens)..where((t) => t.id.equals(existing.id)))
            .write(DeviceTokensCompanion(userId: Value(uid), lastUsedAt: Value(now)));
      }
      return jsonOk({'ok': true});
    });

    r.post('/push/unregister-token', (Request req) async {
      final uid = req.context['userId'] as String?;
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final token = (b['token'] ?? '').toString();
      await (db.delete(db.deviceTokens)
            ..where((t) => t.token.equals(token) & t.userId.equals(uid ?? '')))
          .go();
      return jsonOk({'ok': true});
    });

    // ---------- نسخة احتياطية متسقة من قاعدة البيانات (للمدير) ----------
    r.post('/backup/create', (Request req) async {
      final dir = await Directory.systemTemp.createTemp('sf_backup_');
      final file = p.join(dir.path, 'social_fund_backup.db');
      try {
        // VACUUM INTO ينتج نسخة متسقة حتى مع الكتابة المتزامنة (WAL)
        await db.customStatement("VACUUM INTO '${file.replaceAll("'", "''")}'");
        final bytes = await File(file).readAsBytes();
        return Response.ok(bytes, headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Disposition': 'attachment; filename="social_fund_backup.db"',
        });
      } finally {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      }
    });

    // ---------- سند PDF ----------
    r.get('/vouchers/<id>/pdf', (Request req, String id) async {
      final v = await (db.select(db.vouchers)
            ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();
      if (v == null) return jsonErr(404, 'السند غير موجود');
      try {
        final bytes = await VoucherPdfService.build(v);
        return Response.ok(bytes, headers: {
          'Content-Type': 'application/pdf',
          'Content-Disposition': 'inline; filename="${v.voucherNo}.pdf"',
        });
      } catch (e) {
        print('PDF ERR: $e');
        return jsonErr(500, 'تعذّر إنشاء ملف السند');
      }
    });

    return r;
  }

  Future<String?> _userName(String id) async {
    final u = await (db.select(db.users)..where((t) => t.id.equals(id))).getSingleOrNull();
    return u?.fullName;
  }

  static String _frequencyLabel(String f) => switch (f) {
        'monthly' => 'شهرياً',
        'weekly' => 'أسبوعياً',
        'quarterly' => 'ربع سنوي',
        'yearly' => 'سنوياً',
        _ => f,
      };
}
