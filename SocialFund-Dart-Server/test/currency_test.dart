import 'package:social_fund_dart_server/core/currency_math.dart';
import 'package:social_fund_dart_server/db/database.dart';
import 'package:social_fund_dart_server/db/repositories/currencies_repository.dart';
import 'package:test/test.dart';

void main() {
  test('تحويل وإعادة تسعير', () {
    expect(convertToLocal(100, 2530), 253000);
    expect(convertToLocal(0.5, 2530), 1265);
    expect(rebaseRate(2530, 2530), 1);
    expect(rebaseRate(1, 2530), closeTo(1 / 2530, 1e-12));
  });

  group('CurrenciesRepository', () {
    late AppDatabase db;
    late CurrenciesRepository repo;

    setUp(() async {
      db = AppDatabase.memory();
      await db.seedCurrencies(); // beforeOpen لا يعمل قبل أول استعلام؛ نضمن البذر صراحة
      repo = CurrenciesRepository(db);
    });
    tearDown(() => db.close());

    test('البذر: ريال يمني محلي وافتراضي، والبقية معطلة بسعر 0', () async {
      final all = await repo.list();
      expect(all.map((c) => c.code), containsAll(['YER', 'USD', 'SAR']));
      final yer = all.firstWhere((c) => c.code == 'YER');
      expect([yer.isLocal, yer.isDefault, yer.isActive, yer.rate], [true, true, true, 1.0]);
      expect(all.firstWhere((c) => c.code == 'USD').isActive, isFalse);
      expect(await repo.list(onlyActive: true), hasLength(1));
    });

    test('بلا عملة أو بالمحلية: المبلغ كما هو', () async {
      final a = await repo.resolve(localAmount: 500);
      expect([a.amount, a.currencyCode], [500, null]);
      final b = await repo.resolve(code: 'yer', originalAmount: 7, localAmount: 500);
      expect([b.amount, b.currencyCode], [500, null]);
    });

    test('عملة غير مفعّلة أو بلا سعر مرفوضة', () async {
      expect(() => repo.resolve(code: 'USD', originalAmount: 10, localAmount: 0),
          throwsA(isA<CurrencyException>()));
      expect(() => repo.resolve(code: 'XXX', originalAmount: 10, localAmount: 0),
          throwsA(isA<CurrencyException>()));
    });

    test('لا تفعيل بلا سعر، ثم تحويل صحيح بالسعر الذي يحدده الخادم', () async {
      expect(() => repo.upsert(code: 'USD', nameAr: 'دولار', symbol: r'$', isActive: true),
          throwsA(isA<CurrencyException>()));
      await repo.upsert(code: 'USD', nameAr: 'دولار', symbol: r'$', rate: 2500, isActive: true);
      final r = await repo.resolve(code: 'USD', originalAmount: 10.5, localAmount: 1);
      expect(r.amount, 26250);
      expect(r.exchangeRate, 2500);
      expect(r.originalAmount, 10.5);
      expect(await repo.history('USD'), hasLength(1));
      // تغيير السعر يُسجَّل في السجل
      await repo.upsert(code: 'USD', nameAr: 'دولار', symbol: r'$', rate: 2600);
      expect(await repo.history('USD'), hasLength(2));
    });

    test('قيود: سعر غير موجب، تعطيل المحلية، تعديل سعر المحلية', () async {
      expect(() => repo.upsert(code: 'USD', nameAr: 'د', symbol: r'$', rate: 0),
          throwsA(isA<CurrencyException>()));
      expect(() => repo.upsert(code: 'YER', nameAr: 'ريال', symbol: '﷼', isActive: false),
          throwsA(isA<CurrencyException>()));
      expect(() => repo.upsert(code: 'YER', nameAr: 'ريال', symbol: '﷼', rate: 2),
          throwsA(isA<CurrencyException>()));
      expect(() => repo.upsert(code: 'US', nameAr: 'د', symbol: r'$'),
          throwsA(isA<CurrencyException>()));
    });

    test('تغيير الافتراضية، وتغيير المحلية يعيد تسعير البقية', () async {
      await repo.upsert(code: 'USD', nameAr: 'دولار', symbol: r'$', rate: 2500, isActive: true);
      await repo.upsert(code: 'SAR', nameAr: 'ريال سعودي', symbol: 'ر.س', rate: 625, isActive: true);
      await repo.setConfig(defaultCode: 'USD');
      expect((await repo.byCode('USD'))!.isDefault, isTrue);
      expect((await repo.byCode('YER'))!.isDefault, isFalse);

      await repo.setConfig(localCode: 'USD');
      final usd = (await repo.byCode('USD'))!;
      expect([usd.isLocal, usd.rate], [true, 1.0]);
      expect((await repo.byCode('YER'))!.isLocal, isFalse);
      expect((await repo.byCode('YER'))!.rate, closeTo(1 / 2500, 1e-12));
      expect((await repo.byCode('SAR'))!.rate, closeTo(0.25, 1e-12));
    });
  });
}
