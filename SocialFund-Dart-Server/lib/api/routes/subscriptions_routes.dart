import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/subscriptions_repository.dart';
import '../../db/repositories/members_repository.dart';
import '../../db/repositories/vouchers_repository.dart';
import '../../db/repositories/journal_repository.dart';
import '../../core/currency_math.dart';
import '../../db/repositories/currencies_repository.dart';
import '../middleware.dart';

class SubscriptionsRoutes {
  final AppDatabase db;
  SubscriptionsRoutes(this.db);

  Future<Account?> _accountByCode(String code) =>
      (db.select(db.accounts)..where((t) => t.code.equals(code))).getSingleOrNull();

  /// يولّد قائمة أشهر `YYYY-MM` بدءًا من `start` بعدد `count`.
  static List<String> _expandPeriods(String start, int count) {
    final parts = start.split('-');
    var y = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    final result = <String>[];
    for (var i = 0; i < count; i++) {
      result.add('${y}-${m.toString().padLeft(2, '0')}');
      m++;
      if (m > 12) { m = 1; y++; }
    }
    return result;
  }

  /// استخرج `YYYY-MM` من تاريخ `YYYY-MM-DD`.
  static String _periodFromDate(String date) =>
      date.length >= 7 ? date.substring(0, 7) : date;

  Router get router {
    final r = Router();
    final repo = SubscriptionsRepository(db);

    r.get('/subscriptions', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.list(memberId: q['member_id'], period: q['period'], limit: int.tryParse(q['limit'] ?? '') ?? 200, offset: int.tryParse(q['offset'] ?? '') ?? 0);
      return jsonOk(list.map(_toJson).toList());
    });

    /// ملخص بالشهر: كم اشتراكاً وكم إجمالي في كل شهر
    r.get('/subscriptions/summary-by-period', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.summaryByPeriod(from: q['from'], to: q['to']);
      return jsonOk(list);
    });

    r.post('/subscriptions', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final memberId = (b['member_id'] ?? '').toString().trim();
      final memberName = (b['member_name'] ?? '').toString().trim();
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
      final amountPerMonth = money.amount;
      final paymentDate = (b['payment_date'] ?? '').toString().trim();
      final method = (b['method'] ?? '').toString().trim();

      // الحقول الجديدة:
      final periodStart = (b['period_start'] ?? '').toString().trim().isEmpty
          ? _periodFromDate(paymentDate)   // افتراضيًا شهر الدفع
          : (b['period_start'] as String);
      final periodCount = (b['period_count'] as num?)?.toInt() ?? 1;

      if (memberId.isEmpty || amountPerMonth <= 0 || paymentDate.isEmpty || method.isEmpty) {
        return jsonErr(400, 'member_id, amount, payment_date, method required');
      }
      if (periodCount < 1 || periodCount > 24) {
        return jsonErr(400, 'period_count يجب أن يكون بين 1 و 24');
      }

      final membersRepo = MembersRepository(db);
      final member = await membersRepo.byId(memberId);
      if (member == null) return jsonErr(404, 'Member not found');

      final totalAmount = amountPerMonth * periodCount;
      final periods = _expandPeriods(periodStart, periodCount);

      // ==== الحسابات ====
      String? treasuryId = (b['treasury_account_id'] ?? '').toString().trim();
      String? counterId  = (b['counter_account_id'] ?? '').toString().trim();
      if (treasuryId.isEmpty) {
        final cash = await _accountByCode('1100');
        if (cash == null) return jsonErr(400,
          'لم تُنشأ شجرة الحسابات. افتح "الحسابات والبنوك" واضغط "إنشاء شجرة الحسابات الافتراضية" أولاً.');
        treasuryId = cash.id;
      }
      if (counterId.isEmpty) {
        final income = await _accountByCode('4100');
        if (income == null) return jsonErr(400, 'حساب اشتراكات الأعضاء (4100) غير موجود');
        counterId = income.id;
      }
      final tAcc = await (db.select(db.accounts)..where((t) => t.id.equals(treasuryId!))).getSingleOrNull();
      final cAcc = await (db.select(db.accounts)..where((t) => t.id.equals(counterId!))).getSingleOrNull();
      if (tAcc == null || cAcc == null) return jsonErr(400, 'حساب غير موجود');

      // ==== 1) القيد =====
      final voucherNo = 'V-${DateTime.now().millisecondsSinceEpoch}';
      final journalRepo = JournalRepository(db);
      final periodLabel = periods.length == 1
          ? periods.first
          : '${periods.first} ← ${periods.last}';
      final journalEntryId = await journalRepo.createEntry(
        description: 'اشتراك $periodLabel — ${member.name}',
        entryDate: paymentDate,
        entryType: 'voucher_receipt',
        debitAccountId: tAcc.id,
        creditAccountId: cAcc.id,
        amount: totalAmount.toDouble(),
        reference: voucherNo,
        memberId: memberId,
        createdBy: req.context['userId'] as String?,
      );

      // ==== 2) السند ====
      final vouchersRepo = VouchersRepository(db);
      await vouchersRepo.create(
        voucherNo: voucherNo,
        kind: 'قبض',
        amount: totalAmount,
        voucherDate: paymentDate,
        method: method,
        description: 'اشتراك $periodLabel — ${member.name}',
        issuedByName: 'النظام (تلقائي)',
        memberId: memberId,
        memberName: member.name,
        issuedById: req.context['userId'] as String?,
        treasuryAccountId: tAcc.id,
        counterAccountId: cAcc.id,
        journalEntryId: journalEntryId,
        currencyCode: money.currencyCode,
        originalAmount: money.originalAmount == null ? null : money.originalAmount! * periodCount,
        exchangeRate: money.exchangeRate,
      );

      // ==== 3) صفّ لكل شهر ====
      final created = <Subscription>[];
      for (final period in periods) {
        final s = await repo.create(
          memberId: memberId,
          memberName: memberName.isNotEmpty ? memberName : member.name,
          amount: amountPerMonth,
          paymentDate: paymentDate,
          period: period,
          method: method,
          referenceNo: voucherNo,
          currencyCode: money.currencyCode, originalAmount: money.originalAmount, exchangeRate: money.exchangeRate,
        );
        created.add(s);
      }

      // ==== 4) تحديث مجاميع العضو ====
      await membersRepo.incrementPaid(memberId, totalAmount);

      return jsonOk({
        'subscriptions': created.map(_toJson).toList(),
        'total_amount': totalAmount,
        'periods': periods,
        'voucher_no': voucherNo,
        'journal_entry_id': journalEntryId,
        'treasury_account': tAcc.name,
        'counter_account': cAcc.name,
      });
    });

    r.delete('/subscriptions/<id>', (Request req, String id) async {
      final s = await repo.byId(id);
      if (s == null) return jsonErr(404, 'Subscription not found');
      final membersRepo = MembersRepository(db);
      final m = await membersRepo.byId(s.memberId);
      if (m != null) {
        final newPaid = (m.totalPaid - s.amount).clamp(0, 999999999);
        await (db.update(db.members)..where((t) => t.id.equals(m.id))).write(
          MembersCompanion(totalPaid: Value(newPaid), updatedAt: Value(DateTime.now())),
        );
      }
      await repo.softDelete(id);
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Subscription s) => {
    'id': s.id, 'member_id': s.memberId, 'member_name': s.memberName,
    'amount': s.amount, 'payment_date': s.paymentDate,
    'period': s.period ?? '',
    'method': s.method, 'reference_no': s.referenceNo,
    'currency': s.currencyCode, 'original_amount': s.originalAmount, 'exchange_rate': s.exchangeRate,
  };
}

