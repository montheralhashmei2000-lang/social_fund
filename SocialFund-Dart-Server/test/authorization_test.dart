import 'package:social_fund_dart_server/api/authorization.dart';
import 'package:social_fund_dart_server/core/auth.dart';
import 'package:test/test.dart';

void main() {
  test('المشاهد لا يملك إلا التقارير', () {
    expect(Authorization.allowed('viewer', 'GET', '/financial-reports/trial-balance'), isTrue);
    expect(Authorization.allowed('viewer', 'POST', '/users'), isFalse);
    expect(Authorization.allowed('viewer', 'DELETE', '/members/1'), isFalse);
    expect(Authorization.allowed('viewer', 'GET', '/treasury'), isFalse);
  });

  test('إدارة المستخدمين للمدير فقط', () {
    expect(Authorization.allowed('admin', 'POST', '/users'), isTrue);
    for (final r in ['accountant', 'reviewer', 'viewer']) {
      expect(Authorization.allowed(r, 'POST', '/users'), isFalse, reason: r);
      expect(Authorization.allowed(r, 'GET', '/audit-logs'), isFalse, reason: r);
    }
  });

  test('المساعدات للمراجع والمدير، والخزينة للمحاسب والمدير', () {
    expect(Authorization.allowed('reviewer', 'PATCH', '/aids/1/status'), isTrue);
    expect(Authorization.allowed('accountant', 'PATCH', '/aids/1/status'), isFalse);
    expect(Authorization.allowed('accountant', 'POST', '/treasury'), isTrue);
    expect(Authorization.allowed('reviewer', 'POST', '/treasury'), isFalse);
  });

  test('استثناءات: الرسائل والزملاء وقراءة بيانات الصندوق', () {
    expect(Authorization.allowed('viewer', 'GET', '/messages'), isTrue);
    expect(Authorization.allowed('viewer', 'GET', '/users/colleagues'), isTrue);
    expect(Authorization.allowed('viewer', 'GET', '/fund-settings'), isTrue);
    expect(Authorization.allowed('viewer', 'PUT', '/fund-settings'), isFalse);
    expect(Authorization.allowed('admin', 'PUT', '/fund-settings'), isTrue);
  });

  test('مسار مجهول أو دور مجهول يُرفض', () {
    expect(Authorization.allowed('admin', 'GET', '/unknown'), isFalse);
    expect(Authorization.allowed(null, 'GET', '/members'), isFalse);
    expect(Authorization.allowed('hacker', 'GET', '/members'), isFalse);
  });

  test('توكن تجديد بالصيغة القديمة المزوَّرة مرفوض', () {
    // الصيغة القديمة: <أي شيء>.<base64(userId)> (جزءان فقط)
    expect(TokenService.verifyRefresh('anything.YWRtaW4'), isNull);
    expect(TokenService.verifyRefresh(''), isNull);
    expect(TokenService.verifyRefresh('a.b.c.d'), isNull);
  });
}
