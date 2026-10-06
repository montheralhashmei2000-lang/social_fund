import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/num_parse.dart';

void main() {
  test('الأرقام العربية والفواصل', () {
    expect(parseInt('٥٠٠'), 500);
    expect(parseInt('۱٬۲۰۰'), 1200);
    expect(parseInt('1,500'), 1500);
    expect(parseDouble('١٢٫٥'), 12.5);
    expect(normalizeDigits('٢٠٢٤-٠١-٣١'), '2024-01-31');
  });

  test('إدخال غير صالح يعيد null', () {
    expect(parseInt('abc'), isNull);
    expect(parseInt(''), isNull);
    expect(parseDouble('1.2.3'), isNull);
  });
}
