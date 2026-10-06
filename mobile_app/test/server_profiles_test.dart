import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/server_profiles.dart';

void main() {
  test('http مقبول للشبكة المحلية فقط', () {
    expect(ServerProfiles.normalize('http://192.168.1.50:8000'), 'http://192.168.1.50:8000');
    expect(ServerProfiles.normalize('http://10.0.0.5'), 'http://10.0.0.5');
    expect(ServerProfiles.normalize('http://172.20.1.1'), 'http://172.20.1.1');
    expect(ServerProfiles.normalize('http://localhost:8000/'), 'http://localhost:8000');
    for (final bad in ['http://example.com', 'http://8.8.8.8', 'http://172.32.0.1']) {
      expect(() => ServerProfiles.normalize(bad), throwsFormatException, reason: bad);
    }
  });

  test('بلا مخطط يصبح https، والفارغ/غير الصالح يُرفض', () {
    expect(ServerProfiles.normalize('1-2-3-4.sslip.io'), 'https://1-2-3-4.sslip.io');
    expect(() => ServerProfiles.normalize('  '), throwsFormatException);
    expect(() => ServerProfiles.normalize('ftp://x.com'), throwsFormatException);
  });
}
