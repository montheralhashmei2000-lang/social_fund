import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:social_fund_dart_server/api/router.dart';
import 'package:social_fund_dart_server/db/database.dart';
import 'package:social_fund_dart_server/db/seed.dart';
import 'package:test/test.dart';

/// إعدادات النظام + سجل العمليات + ترقيم السندات + السياسات المفروضة من الخادم.
void main() {
  late AppDatabase db;
  late Handler app;
  late String admin;

  Future<(int, dynamic)> call(String method, String path, {Object? body, String? token}) async {
    final res = await app(Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? '' : jsonEncode(body),
      headers: {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
    ));
    final text = await res.readAsString();
    dynamic data;
    try {
      data = text.isEmpty ? null : jsonDecode(text);
    } catch (_) {
      data = text;
    }
    return (res.statusCode, data);
  }

  Future<String> login(String u, String p) async {
    final (s, r) = await call('POST', '/auth/login', body: {'username': u, 'password': p});
    expect(s, 200, reason: 'login $u: $r');
    return r['access_token'] as String;
  }

  setUpAll(() async {
    db = AppDatabase.memory();
    await seedDefaultAdmin(db);
    app = buildHandler(db);
    admin = await login('admin', 'Admin@12345');
    await call('POST', '/accounts/seed-defaults', body: {}, token: admin);
  });
  tearDownAll(() => db.close());

  Future<String> member(String name, String nid) async {
    final (_, m) = await call('POST', '/members', token: admin, body: {
      'name': name, 'national_id': nid, 'phone': '0777', 'monthly_subscription': 100,
    });
    return m['id'] as String;
  }

  test('الإعدادات: قيم افتراضية، تعديل صالح، ورفض المجهول وغير الصالح دون كتابة جزئية', () async {
    final (s, all) = await call('GET', '/app-settings', token: admin);
    expect(s, 200);
    expect((all['aids.types'] as List), contains('مساعدة طارئة'));
    expect(all['aids.require_second_approver'], false);
    expect(all['accounting.fiscal_year_start_month'], 1);

    var (s2, upd) = await call('PUT', '/app-settings', token: admin, body: {
      'aids.types': ['طبية', 'تعليمية', 'طبية', '  '], // تكرار وفراغ يُنظَّفان
      'subscriptions.default_amount': 500,
    });
    expect(s2, 200);
    expect(upd['aids.types'], ['طبية', 'تعليمية']);
    expect(upd['subscriptions.default_amount'], 500);

    // مفتاح مجهول، شهر خارج النطاق، بادئة غير صالحة
    expect((await call('PUT', '/app-settings', token: admin, body: {'nope': 1})).$1, 400);
    expect((await call('PUT', '/app-settings', token: admin, body: {'accounting.fiscal_year_start_month': 13})).$1, 400);
    expect((await call('PUT', '/app-settings', token: admin, body: {'vouchers.receipt_prefix': 'ر س'})).$1, 400);
    // كل أو لا شيء: طلب فيه صالح وغير صالح لا يغيّر الصالح
    expect((await call('PUT', '/app-settings', token: admin, body: {
      'subscriptions.default_amount': 900, 'reports.default_format': 'docx'})).$1, 400);
    final (_, after) = await call('GET', '/app-settings', token: admin);
    expect(after['subscriptions.default_amount'], 500);
  });

  test('الإعدادات: القراءة لكل مستخدم والتعديل لمن يملك settings فقط', () async {
    await call('POST', '/users', token: admin,
        body: {'username': 'viewer1', 'password': 'Viewer@12345', 'full_name': 'مشاهد', 'role': 'viewer'});
    final v = await login('viewer1', 'Viewer@12345');
    expect((await call('GET', '/app-settings', token: v)).$1, 200);
    expect((await call('PUT', '/app-settings', token: v, body: {'aids.max_amount': 5})).$1, 403);
  });

  test('سجل العمليات: عمليات الكتابة والدخول تُسجَّل، والقراءة لا', () async {
    final id = await member('عضو التدقيق', '555111222');
    await call('GET', '/members', token: admin);
    final (s, logs) = await call('GET', '/audit-logs?limit=500', token: admin);
    expect(s, 200);
    final list = (logs as List).cast<Map<String, dynamic>>();
    expect(list.any((l) => l['action'] == 'login' && l['user_name'] == 'المدير العام'), isTrue);
    expect(
        list.any((l) =>
            l['action'] == 'create' && l['resource_type'] == 'members' && (l['summary'] as String).contains('عضو')),
        isTrue);
    expect(list.any((l) => l['resource_id'] == id), isTrue);
    expect(list.where((l) => l['summary'] == 'GET /members'), isEmpty);

    // محاولة دخول فاشلة تُسجَّل باسم المستخدم المُحاول بلا كلمة المرور
    await call('POST', '/auth/login', body: {'username': 'ghost', 'password': 'wrong-pass-1'});
    final (_, logs2) = await call('GET', '/audit-logs?limit=500', token: admin);
    final failed = (logs2 as List).where((l) => l['action'] == 'login_failed').toList();
    expect(failed, isNotEmpty);
    expect(jsonEncode(failed), isNot(contains('wrong-pass-1')));
  });

  test('ترقيم السندات تسلسلي بالبادئة من الإعدادات', () async {
    await call('PUT', '/app-settings', token: admin, body: {'vouchers.receipt_prefix': 'RC'});
    Future<String> receipt() async {
      final (s, v) = await call('POST', '/vouchers', token: admin, body: {
        'kind': 'قبض', 'amount': 100, 'voucher_date': '2026-10-03', 'method': 'نقداً',
        'description': 'تبرع', 'party_name': 'محسن',
      });
      expect(s, 200, reason: '$v');
      return v['voucher_no'] as String;
    }

    final a = await receipt();
    final b = await receipt();
    expect(a, matches(RegExp(r'^RC-2026-\d{4}$')));
    final n1 = int.parse(a.split('-').last), n2 = int.parse(b.split('-').last);
    expect(n2, n1 + 1);
  });

  test('منع السحب فوق الرصيد يُفرض عند تفعيله فقط', () async {
    Future<(int, dynamic)> pay(int amount) => call('POST', '/vouchers', token: admin, body: {
          'kind': 'صرف', 'amount': amount, 'voucher_date': '2026-10-03', 'method': 'نقداً',
          'description': 'مصروف', 'party_name': 'مورد',
        });

    await call('PUT', '/app-settings', token: admin, body: {'vouchers.block_overdraft': false});
    expect((await pay(1)).$1, 200); // مسموح: السياسة معطّلة

    await call('PUT', '/app-settings', token: admin, body: {'vouchers.block_overdraft': true});
    final (s, r) = await pay(900000000);
    expect(s, 400);
    expect(r['detail'], contains('غير كافٍ'));
    await call('PUT', '/app-settings', token: admin, body: {'vouchers.block_overdraft': false});
  });

  test('المساعدات: سقف المبلغ واعتماد مستخدم ثانٍ عند تفعيل السياسة', () async {
    final m = await member('عضو السياسات', '777444111');
    Future<(int, dynamic)> aid(int amount) => call('POST', '/aids', token: admin, body: {
          'member_id': m, 'aid_type': 'طارئة', 'amount': amount, 'request_date': '2026-10-03'});

    await call('PUT', '/app-settings', token: admin, body: {'aids.max_amount': 1000});
    expect((await aid(1001)).$1, 400);
    final (s, created) = await aid(1000);
    expect(s, 200);
    await call('PUT', '/app-settings', token: admin, body: {'aids.max_amount': 0}); // بلا حد

    // السياسة معطّلة: المسجّل يعتمد بنفسه
    String id = created['id'];
    expect((await call('PATCH', '/aids/$id/status', token: admin, body: {'status': 'معتمدة'})).$1, 200);

    // مفعّلة: المسجّل نفسه ممنوع، ومستخدم آخر مسموح
    await call('PUT', '/app-settings', token: admin, body: {'aids.require_second_approver': true});
    final (_, c2) = await aid(500);
    id = c2['id'];
    final (deny, r) = await call('PATCH', '/aids/$id/status', token: admin, body: {'status': 'معتمدة'});
    expect(deny, 403);
    expect(r['detail'], contains('سياسة'));
    await call('POST', '/users', token: admin,
        body: {'username': 'rev1', 'password': 'Review@12345', 'full_name': 'مراجع', 'role': 'admin'});
    final other = await login('rev1', 'Review@12345');
    expect((await call('PATCH', '/aids/$id/status', token: other, body: {'status': 'معتمدة'})).$1, 200);
    await call('PUT', '/app-settings', token: admin, body: {'aids.require_second_approver': false});
  });
}
