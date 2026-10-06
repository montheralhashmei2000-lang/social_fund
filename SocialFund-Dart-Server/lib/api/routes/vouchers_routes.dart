import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/vouchers_repository.dart';
import '../../db/repositories/journal_repository.dart';
import '../../core/currency_math.dart';
import '../../db/repositories/currencies_repository.dart';
import '../middleware.dart';

class VouchersRoutes {
  final AppDatabase db;
  VouchersRoutes(this.db);

  Future<String> _issuedByName(Request req, String provided) async {
    if (provided.isNotEmpty) return provided;
    final uid = req.context['userId'] as String?;
    if (uid == null) return 'النظام';
    final u = await (db.select(db.users)..where((t) => t.id.equals(uid))).getSingleOrNull();
    return u?.fullName ?? 'النظام';
  }

  Router get router {
    final r = Router();
    final repo = VouchersRepository(db);
    final journal = JournalRepository(db);

    r.get('/vouchers', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.list(kind: q['kind'], limit: int.tryParse(q['limit'] ?? '') ?? 200, offset: int.tryParse(q['offset'] ?? '') ?? 0);
      return jsonOk(list.map(_toJson).toList());
    });

    r.get('/vouchers/<id>', (Request req, String id) async {
      final v = await repo.byId(id);
      if (v == null) return jsonErr(404, 'Voucher not found');
      return jsonOk(_toJson(v));
    });

    r.post('/vouchers', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final kind = (b['kind'] ?? '').toString().trim();
      final rawAmount = (b['amount'] as num?)?.toInt() ?? 0;
      final ResolvedMoney money;
      try {
        money = await CurrenciesRepository(db).resolve(
          code: b['currency'] as String?,
          originalAmount: b['original_amount'] as num?,
          localAmount: rawAmount,
        );
      } on CurrencyException catch (e) {
        return jsonErr(400, e.message);
      }
      final amount = money.amount;
      final voucherDate = (b['voucher_date'] ?? '').toString().trim();
      final method = (b['method'] ?? '').toString().trim();
      final description = (b['description'] ?? '').toString().trim();

      // issued_by_name اختياري — نستخدم اسم المستخدم الحالي
      final issuedByName = await _issuedByName(req, (b['issued_by_name'] ?? '').toString().trim());

      if (kind.isEmpty || amount <= 0 || voucherDate.isEmpty || method.isEmpty) {
        return jsonErr(400, 'kind, amount, voucher_date, method required');
      }

      // ==== الحسابات ====
      String treasuryId = (b['treasury_account_id'] ?? '').toString().trim();
      String counterId = (b['counter_account_id'] ?? '').toString().trim();

      // إن لم تُرسل، ابحث عن الافتراضية
      if (treasuryId.isEmpty) {
        final cash = await (db.select(db.accounts)..where((t) => t.code.equals('1100'))).getSingleOrNull();
        if (cash == null) {
          return jsonErr(400, 'لم تُنشأ شجرة الحسابات. افتح "الحسابات والبنوك" واضغط "إنشاء شجرة الحسابات الافتراضية" أولاً.');
        }
        treasuryId = cash.id;
      }
      if (counterId.isEmpty) {
        // سند قبض: حساب الإيراد (4100)
        // سند صرف: حساب المساعدات النقدية (5100)
        final code = kind == 'صرف' ? '5100' : '4100';
        final counter = await (db.select(db.accounts)..where((t) => t.code.equals(code))).getSingleOrNull();
        if (counter == null) {
          return jsonErr(400, 'حساب مقابل بالكود $code غير موجود. أنشئ شجرة الحسابات أولًا.');
        }
        counterId = counter.id;
      }

      final tAcc = await (db.select(db.accounts)..where((t) => t.id.equals(treasuryId))).getSingleOrNull();
      final cAcc = await (db.select(db.accounts)..where((t) => t.id.equals(counterId))).getSingleOrNull();
      if (tAcc == null || cAcc == null) return jsonErr(400, 'حساب محاسبي غير موجود');

      final isReceipt = kind == 'قبض';
      final debitId  = isReceipt ? treasuryId : counterId;
      final creditId = isReceipt ? counterId : treasuryId;

      final voucherNo = (b['voucher_no'] ?? '').toString().trim().isEmpty
          ? 'V-${DateTime.now().millisecondsSinceEpoch}'
          : b['voucher_no'].toString();

      // 1) القيد المحاسبي
      final entryId = await journal.createEntry(
        description: description.isEmpty ? 'سند $kind رقم $voucherNo' : description,
        entryDate: voucherDate,
        entryType: isReceipt ? 'voucher_receipt' : 'voucher_payment',
        debitAccountId: debitId,
        creditAccountId: creditId,
        amount: amount.toDouble(),
        reference: voucherNo,
        memberId: b['member_id'] as String?,
        createdBy: req.context['userId'] as String?,
      );

      // 2) السند
      final v = await repo.create(
        voucherNo: voucherNo, kind: kind, amount: amount,
        voucherDate: voucherDate, method: method,
        description: description, issuedByName: issuedByName,
        memberId: b['member_id'] as String?, memberName: b['member_name'] as String?,
        donorId: b['donor_id'] as String?, beneficiaryId: b['beneficiary_id'] as String?,
        partyName: b['party_name'] as String?, issuedById: req.context['userId'] as String?,
        treasuryAccountId: treasuryId,
        counterAccountId: counterId,
        journalEntryId: entryId,
        currencyCode: money.currencyCode, originalAmount: money.originalAmount, exchangeRate: money.exchangeRate,
      );

      return jsonOk(_toJson(v));
    });

    r.post('/vouchers/<id>/void', (Request req, String id) async {
      final v = await repo.byId(id);
      if (v == null) return jsonErr(404, 'Voucher not found');
      if (v.status == 'ملغي') return jsonErr(400, 'already voided');

      // قيد عكسي يبقي القيد الأصلي موثقاً (لا حذف): الاتجاه معكوس تماماً.
      final tId = v.treasuryAccountId, cId = v.counterAccountId;
      if (tId != null && cId != null) {
        final isReceipt = v.kind == 'قبض';
        await journal.createEntry(
          description: 'عكس السند ${v.voucherNo}',
          entryDate: DateTime.now().toIso8601String().split('T').first,
          entryType: 'voucher_void',
          debitAccountId: isReceipt ? cId : tId,
          creditAccountId: isReceipt ? tId : cId,
          amount: v.amount.toDouble(),
          reference: v.voucherNo,
          voucherId: v.id,
          createdBy: req.context['userId'] as String?,
        );
      }

      // سند اشتراك: تُلغى صفوف الاشتراكات المرتبطة وتُخصم من مجاميع العضو.
      final subs = await (db.select(db.subscriptions)
            ..where((t) => t.referenceNo.equals(v.voucherNo) & t.deleted.equals(false)))
          .get();
      var refunded = 0;
      for (final s in subs) {
        refunded += s.amount;
        await (db.update(db.subscriptions)..where((t) => t.id.equals(s.id))).write(
          SubscriptionsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())),
        );
      }
      if (refunded > 0 && v.memberId != null) {
        final m = await (db.select(db.members)..where((t) => t.id.equals(v.memberId!))).getSingleOrNull();
        if (m != null) {
          await (db.update(db.members)..where((t) => t.id.equals(m.id))).write(
            MembersCompanion(
              totalPaid: Value((m.totalPaid - refunded).clamp(0, 999999999)),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }

      await (db.update(db.vouchers)..where((t) => t.id.equals(id))).write(
        VouchersCompanion(status: const Value('ملغي'), updatedAt: Value(DateTime.now())),
      );
      return jsonOk(_toJson((await repo.byId(id))!));
    });

    r.delete('/vouchers/<id>', (Request req, String id) async {
      final ok = await repo.softDelete(id);
      if (!ok) return jsonErr(404, 'Voucher not found');
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Voucher v) => {
    'id': v.id, 'voucher_no': v.voucherNo, 'kind': v.kind,
    'member_id': v.memberId, 'member_name': v.memberName,
    'donor_id': v.donorId, 'beneficiary_id': v.beneficiaryId,
    'party_name': v.partyName, 'amount': v.amount,
    'voucher_date': v.voucherDate, 'method': v.method,
    'description': v.description, 'issued_by_name': v.issuedByName,
    'status': v.status,
    'treasury_account_id': v.treasuryAccountId,
    'counter_account_id': v.counterAccountId,
    'journal_entry_id': v.journalEntryId,
    'currency': v.currencyCode, 'original_amount': v.originalAmount, 'exchange_rate': v.exchangeRate,
  };
}
