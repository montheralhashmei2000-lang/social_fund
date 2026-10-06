import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/currency.dart';
import 'package:social_fund_app/widgets/ui.dart';

const yer = Currency(
    code: 'YER', nameAr: 'ريال يمني', symbol: '﷼', decimals: 0, rate: 1,
    isLocal: true, isDefault: true, isActive: true);
const usd = Currency(
    code: 'USD', nameAr: 'دولار', symbol: r'$', decimals: 2, rate: 2500,
    isLocal: false, isDefault: false, isActive: true);

void main() {
  tearDown(() {
    CurrencyFormat.local = null;
    CurrencyFormat.display = null;
  });

  test('تحويل من/إلى المحلية بتقريب الخادم نفسه', () {
    expect(usd.toLocal(10.5), 26250);
    expect(usd.toLocal(0.0002), 1); // 0.5 تُقرَّب لأعلى
    expect(usd.fromLocal(26250), 10.5);
    expect(const Currency(code: 'X', nameAr: '', symbol: '', decimals: 2, rate: 0,
        isLocal: false, isDefault: false, isActive: false).fromLocal(10), 0);
  });

  test('money() قبل التحميل: ريال بلا كسور', () {
    expect(money(1500), '1,500 ﷼');
  });

  test('money() بالمحلية ثم بعملة عرض أخرى', () {
    CurrencyFormat.local = yer;
    CurrencyFormat.display = yer;
    expect(money(250000), '250,000 ﷼');
    CurrencyFormat.display = usd;
    expect(money(250000), r'100.00 $');
    expect(money(1250), r'0.50 $');
  });

  test('عملة عرض بلا سعر تعود للمحلية بدل القسمة على صفر', () {
    CurrencyFormat.local = yer;
    CurrencyFormat.display = const Currency(code: 'EUR', nameAr: '', symbol: '€', decimals: 2,
        rate: 0, isLocal: false, isDefault: false, isActive: true);
    expect(money(500), '500 ﷼');
  });

  test('money2 تحتفظ بالكسور في المحلية فقط', () {
    CurrencyFormat.local = yer;
    CurrencyFormat.display = yer;
    expect(money2(10.5), '10.50 ﷼');
    expect(money2(10), '10 ﷼');
  });

  test('أصل المبلغ يُقرأ من الاستجابة', () {
    final o = MoneyOrigin.from({'currency': 'USD', 'original_amount': 100.5, 'exchange_rate': 2530});
    expect(o!.label, '100.5 USD @ 2,530');
    expect(MoneyOrigin.from({'currency': null, 'original_amount': null}), isNull);
    expect(MoneyOrigin.from({'amount': 5}), isNull);
  });
}
