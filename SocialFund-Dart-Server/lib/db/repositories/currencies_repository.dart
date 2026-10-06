import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../../core/currency_math.dart';

class CurrencyException implements Exception {
  final String message;
  CurrencyException(this.message);
  @override
  String toString() => message;
}

class CurrenciesRepository {
  final AppDatabase db;
  CurrenciesRepository(this.db);

  Future<List<Currency>> list({bool onlyActive = false}) {
    final q = db.select(db.currencies);
    if (onlyActive) q.where((t) => t.isActive.equals(true));
    q.orderBy([(t) => OrderingTerm.desc(t.isLocal), (t) => OrderingTerm.asc(t.code)]);
    return q.get();
  }

  Future<Currency?> byCode(String code) => (db.select(db.currencies)
        ..where((t) => t.code.equals(code.toUpperCase())))
      .getSingleOrNull();

  Future<Currency> local() async =>
      (await (db.select(db.currencies)..where((t) => t.isLocal.equals(true))).getSingle());

  /// يحوّل مبلغاً مدخلاً إلى العملة المحلية بالسعر الحالي في الخادم (المرجع الوحيد؛
  /// لا نثق بسعر يرسله العميل). بلا عملة أو بالعملة المحلية: المبلغ كما هو.
  Future<ResolvedMoney> resolve({
    String? code, num? originalAmount, required int localAmount,
  }) async {
    final c = (code ?? '').trim().toUpperCase();
    final loc = await local();
    if (c.isEmpty || c == loc.code) {
      return ResolvedMoney(amount: localAmount);
    }
    final cur = await byCode(c);
    if (cur == null || !cur.isActive) throw CurrencyException('عملة غير متاحة: $c');
    if (cur.rate <= 0) throw CurrencyException('لا يوجد سعر صرف للعملة $c');
    final orig = originalAmount?.toDouble() ?? 0;
    if (orig <= 0) throw CurrencyException('المبلغ بالعملة $c مطلوب');
    final converted = convertToLocal(orig, cur.rate);
    if (converted <= 0) throw CurrencyException('المبلغ بعد التحويل صغير جداً');
    return ResolvedMoney(amount: converted, currencyCode: cur.code, originalAmount: orig, exchangeRate: cur.rate);
  }

  Future<Currency> upsert({
    required String code, required String nameAr, required String symbol,
    int decimals = 2, double? rate, bool? isActive, String? changedBy,
  }) async {
    final c = code.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(c)) throw CurrencyException('رمز العملة 3 أحرف لاتينية (مثل USD)');
    if (rate != null && rate <= 0) throw CurrencyException('سعر الصرف يجب أن يكون أكبر من صفر');
    final now = DateTime.now();
    final existing = await byCode(c);
    if (existing == null) {
      await db.into(db.currencies).insert(CurrenciesCompanion.insert(
        id: const Uuid().v4(), code: c, nameAr: nameAr, symbol: symbol,
        decimals: Value(decimals), rate: Value(rate ?? 0),
        isActive: Value(isActive ?? false), createdAt: now, updatedAt: now,
      ));
      if (rate != null) await _logRate(c, rate, changedBy);
    } else {
      if (existing.isLocal && rate != null && rate != 1) {
        throw CurrencyException('سعر العملة المحلية ثابت = 1');
      }
      if (isActive == true && (rate ?? existing.rate) <= 0) {
        throw CurrencyException('أدخل سعر الصرف قبل تفعيل العملة');
      }
      if (isActive == false && (existing.isLocal || existing.isDefault)) {
        throw CurrencyException('لا يمكن تعطيل العملة المحلية أو الافتراضية');
      }
      await (db.update(db.currencies)..where((t) => t.id.equals(existing.id))).write(
        CurrenciesCompanion(
          nameAr: Value(nameAr), symbol: Value(symbol), decimals: Value(decimals),
          rate: rate != null ? Value(rate) : const Value.absent(),
          isActive: isActive != null ? Value(isActive) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
      if (rate != null && rate != existing.rate) await _logRate(c, rate, changedBy);
    }
    return (await byCode(c))!;
  }

  Future<void> _logRate(String code, double rate, String? by) =>
      db.into(db.currencyRates).insert(CurrencyRatesCompanion.insert(
        id: const Uuid().v4(), currencyCode: code, rate: rate,
        changedBy: Value(by), createdAt: DateTime.now(),
      ));

  Future<List<CurrencyRate>> history(String code, {int limit = 50}) =>
      (db.select(db.currencyRates)
            ..where((t) => t.currencyCode.equals(code.toUpperCase()))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  /// يضبط العملة المحلية و/أو الافتراضية. تغيير المحلية يعيد تسعير الباقي نسبةً
  /// إلى المحلية الجديدة حتى تبقى الأسعار متسقة.
  Future<void> setConfig({String? localCode, String? defaultCode}) async {
    await db.transaction(() async {
      if (localCode != null) {
        final newLocal = await byCode(localCode);
        if (newLocal == null || !newLocal.isActive) throw CurrencyException('عملة محلية غير صالحة');
        final old = await local();
        if (old.code != newLocal.code) {
          if (newLocal.rate <= 0) throw CurrencyException('أدخل سعر صرف للعملة الجديدة أولاً');
          final all = await list();
          for (final c in all) {
            final r = rebaseRate(c.rate, newLocal.rate);
            await (db.update(db.currencies)..where((t) => t.id.equals(c.id))).write(
              CurrenciesCompanion(
                rate: Value(c.code == newLocal.code ? 1 : r),
                isLocal: Value(c.code == newLocal.code),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      }
      if (defaultCode != null) {
        final d = await byCode(defaultCode);
        if (d == null || !d.isActive) throw CurrencyException('عملة افتراضية غير صالحة');
        await db.update(db.currencies).write(const CurrenciesCompanion(isDefault: Value(false)));
        await (db.update(db.currencies)..where((t) => t.id.equals(d.id)))
            .write(const CurrenciesCompanion(isDefault: Value(true)));
      }
    });
  }
}
