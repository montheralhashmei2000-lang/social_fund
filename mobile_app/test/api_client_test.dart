import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/api_client.dart';

/// محوّل شبكة وهمي: يرد حسب المسار ورأس Authorization.
class _FakeAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
      RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    return handler(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int code, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json']
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeAdapter adapter;
  final c = ApiClient.instance;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    adapter = _FakeAdapter();
    c.dio.httpClientAdapter = adapter;
    await c.saveTokens('old', 'r1');
    c.sessionExpired.value = 0;
  });

  test('401 ثم تجديد ناجح ثم إعادة الطلب بالرمز الجديد', () async {
    adapter.handler = (o) {
      if (o.path == '/auth/refresh') {
        return _json(200, {'access_token': 'new', 'refresh_token': 'r2'});
      }
      return o.headers['Authorization'] == 'Bearer new'
          ? _json(200, {'ok': true})
          : _json(401, {'detail': 'expired'});
    };
    final r = await c.request('GET', '/members');
    expect(r['ok'], true);
    expect(c.sessionExpired.value, 0);
  });

  test('فشل التجديد يمسح الرموز ويُشعر بانتهاء الجلسة', () async {
    adapter.handler = (o) => _json(401, {'detail': 'expired'});
    await expectLater(c.request('GET', '/members'), throwsA(isA<AuthException>()));
    expect(c.hasTokens, false);
    expect(c.sessionExpired.value, 1);
  });

  test('خطأ 500 يظهر برسالة خادم لا كخطأ شبكة', () async {
    adapter.handler = (o) => _json(500, {'detail': 'boom'});
    await expectLater(
      c.request('GET', '/x'),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 500)
          .having((e) => e is NetworkException, 'network', false)),
    );
  });

  test('رسالة التحقق (422) من قائمة detail', () async {
    adapter.handler = (o) => _json(422, {
          'detail': [
            {'msg': 'حقل مطلوب'}
          ]
        });
    await expectLater(
        c.request('POST', '/x', data: {}),
        throwsA(isA<ApiException>().having((e) => e.message, 'msg', 'حقل مطلوب')));
  });

  test('requestBytes يرمي رسالة الخادم عند الخطأ', () async {
    adapter.handler = (o) => _json(403, {'detail': 'ممنوع'});
    await expectLater(
        c.requestBytes('GET', '/reports/a/pdf'),
        throwsA(isA<ApiException>().having((e) => e.message, 'msg', 'ممنوع')));
  });
}
