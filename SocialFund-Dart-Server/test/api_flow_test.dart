import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:shelf/shelf.dart';
import 'package:social_fund_dart_server/api/router.dart';
import 'package:social_fund_dart_server/db/database.dart';
import 'package:social_fund_dart_server/db/seed.dart';
import 'package:test/test.dart';

/// اختبار تكاملي: يمر عبر كل الطبقات (middleware + صلاحيات + مسارات + قاعدة
/// بيانات في الذاكرة) دون شبكة.
void main() {
  late AppDatabase db;
  late Handler app;

  Future<(int, dynamic)> call(String method, String path,
      {Object? body, String? token}) async {
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

  late String admin;

  setUpAll(() async {
    db = AppDatabase.memory();
    await seedDefaultAdmin(db);
    app = buildHandler(db);
    admin = await login('admin', 'Admin@12345');
    await call('POST', '/accounts/seed-defaults', body: {}, token: admin);
  });
  tearDownAll(() => db.close());

  test('توكن تجديد مزوَّر مرفوض والحقيقي يعمل', () async {
    final (_, r) = await call('POST', '/auth/login',
        body: {'username': 'admin', 'password': 'Admin@12345'});
    final uid = r['user']['id'] as String;
    final forged = 'xxxx.${base64Url.encode(utf8.encode(uid)).replaceAll('=', '')}';
    expect((await call('POST', '/auth/refresh', body: {'refresh_token': forged})).$1, 401);
    expect((await call('POST', '/auth/refresh', body: {'refresh_token': r['refresh_token']})).$1, 200);
    expect((await call('POST', '/auth/refresh', body: {'refresh_token': r['access_token']})).$1, 401);
  });

  test('الصلاحيات تُفرض في الخادم', () async {
    await call('POST', '/users',
        body: {'username': 'v1', 'password': 'Viewer@1234', 'full_name': 'م', 'role': 'viewer'},
        token: admin);
    final viewer = await login('v1', 'Viewer@1234');
    expect(
        (await call('POST', '/users',
                body: {'username': 'evil', 'password': 'Evil@12345', 'full_name': 'x', 'role': 'admin'},
                token: viewer))
            .$1,
        403);
    expect((await call('GET', '/treasury', token: viewer)).$1, 403);
    expect((await call('GET', '/currencies', token: viewer)).$1, 200);
    expect(
        (await call('POST', '/users',
                body: {'username': 'a', 'password': 'short', 'full_name': 'x', 'role': 'viewer'},
                token: admin))
            .$1,
        400);
    expect((await call('GET', '/treasury')).$1, 401);
  });

  test('عملات: التحويل بسعر الخادم، والمجاميع بالمحلية، والسجل التاريخي', () async {
    expect((await call('PUT', '/currencies/USD', body: {'is_active': true}, token: admin)).$1, 400);
    final (s, r) =
        await call('PUT', '/currencies/USD', body: {'rate': 2500, 'is_active': true}, token: admin);
    expect([s, r['rate']], [200, 2500]);

    final (s2, e) = await call('POST', '/treasury', token: admin, body: {
      'type': 'إيراد',
      'category': 'تبرعات',
      'description': 'د',
      'amount': 1,
      'currency': 'USD',
      'original_amount': 100,
      'entry_date': '2026-10-03',
    });
    expect(s2, 200);
    expect([e['amount'], e['currency'], e['original_amount'], e['exchange_rate']],
        [250000, 'USD', 100, 2500]);

    // تغيير السعر لا يمس الصفوف القديمة
    await call('PUT', '/currencies/USD', body: {'rate': 2600}, token: admin);
    final (_, list) = await call('GET', '/treasury', token: admin);
    expect((list as List).first['amount'], 250000);
    expect(list.first['exchange_rate'], 2500);

    expect(
        (await call('POST', '/treasury', token: admin, body: {
          'type': 'إيراد',
          'category': 'x',
          'description': 'x',
          'amount': 1,
          'currency': 'SAR',
          'original_amount': 10,
          'entry_date': '2026-10-03',
        }))
            .$1,
        400); // عملة غير مفعّلة
    final (_, h) = await call('GET', '/currencies/USD/history', token: admin);
    expect((h as List).length, 2);
  });

  test('المساعدات: انتقالات الحالة الصحيحة فقط', () async {
    final (_, m) = await call('POST', '/members', token: admin, body: {
      'name': 'عضو',
      'national_id': '111222333',
      'phone': '0777',
      'monthly_subscription': 500
    });
    final (_, aid) = await call('POST', '/aids', token: admin, body: {
      'member_id': m['id'],
      'aid_type': 'مساعدة طارئة',
      'amount': 1000,
      'request_date': '2026-10-03'
    });
    Future<int> st(String s) async =>
        (await call('PATCH', '/aids/${aid['id']}/status', body: {'status': s}, token: admin)).$1;
    expect(await st('مصروفة'), 400); // قبل الاعتماد
    expect(await st('معتمدة'), 200);
    expect(await st('مرفوضة'), 400); // بعد الاعتماد
    expect(await st('مصروفة'), 200);
    expect(await st('معتمدة'), 400); // الصرف نهائي
    expect(await st('bogus'), 400);
  });

  test('أمان: لا تجاوز لانتقالات المساعدة بـ PUT ولا حذف لمصروفة، والمدير لا يقفل نفسه', () async {
    final (_, m) = await call('POST', '/members', token: admin, body: {
      'name': 'عضو أمان', 'national_id': '999888777', 'phone': '0700', 'monthly_subscription': 100
    });
    final (_, aid) = await call('POST', '/aids', token: admin, body: {
      'member_id': m['id'], 'aid_type': 'طارئة', 'amount': 500, 'request_date': '2026-10-03'
    });
    // PUT كان يقبل أي حالة واسم مراجع من العميل
    final put = await call('PUT', '/aids/${aid['id']}',
        body: {'status': 'مصروفة', 'reviewer_name': 'مزوَّر'}, token: admin);
    expect(put.$1, isNot(200));
    final (_, cur) = await call('GET', '/aids/${aid['id']}', token: admin);
    expect(cur['status'], 'قيد المراجعة');
    // الصرف النهائي لا يُحذف
    await call('PATCH', '/aids/${aid['id']}/status', body: {'status': 'معتمدة'}, token: admin);
    await call('PATCH', '/aids/${aid['id']}/status', body: {'status': 'مصروفة'}, token: admin);
    expect((await call('DELETE', '/aids/${aid['id']}', token: admin)).$1, 400);
    // المدير لا يعطّل حسابه ولا يخفض دوره
    final (_, me) = await call('GET', '/auth/me', token: admin);
    expect((await call('PUT', '/users/${me['id']}', body: {'is_active': false}, token: admin)).$1, 400);
    expect((await call('PUT', '/users/${me['id']}', body: {'role': 'viewer'}, token: admin)).$1, 400);
  });

  test('ترويسات الأمان موجودة في الردود', () async {
    final res = await app(Request('GET', Uri.parse('http://localhost/health')));
    expect(res.headers['x-content-type-options'], 'nosniff');
    expect(res.headers['x-frame-options'], 'DENY');
  });

  test('إلغاء السند: قيد عكسي وبقاء السند ملغياً واستبعاده من إجمالي المانح', () async {
    final (_, d) = await call('POST', '/donors', token: admin, body: {'name': 'محسن'});
    final (s, v) = await call('POST', '/vouchers', token: admin, body: {
      'kind': 'قبض',
      'amount': 7000,
      'voucher_date': '2026-10-03',
      'method': 'نقداً',
      'description': 'تبرع',
      'donor_id': d['id'],
    });
    expect(s, 200);
    var (_, det) = await call('GET', '/donors/${d['id']}', token: admin);
    expect(det['total_donated'], 7000);

    final (_, before) = await call('GET', '/journal', token: admin);
    final (s2, voided) = await call('POST', '/vouchers/${v['id']}/void', body: {}, token: admin);
    expect([s2, voided['status']], [200, 'ملغي']);
    final (_, after) = await call('GET', '/journal', token: admin);
    expect((after as List).length, (before as List).length + 1);
    expect(after.any((e) => e['entry_type'] == 'voucher_void'), isTrue);
    expect((await call('POST', '/vouchers/${v['id']}/void', body: {}, token: admin)).$1, 400);

    (_, det) = await call('GET', '/donors/${d['id']}', token: admin);
    expect(det['total_donated'], 0);
  });

  test('القيد اليدوي يجب أن يتوازن، والتحويل لا يكون لنفس الحساب', () async {
    final (_, accs) = await call('GET', '/accounts', token: admin);
    final liquid =
        (accs as List)
            .where((a) => a['is_postable'] != false && (a['is_cash'] == true || a['is_bank'] == true))
            .toList();
    final a1 = liquid[0]['id'], a2 = liquid[1]['id'];
    List<Map> lines(num d, num c) => [
          {'account_id': a1, 'debit': d, 'credit': 0},
          {'account_id': a2, 'debit': 0, 'credit': c},
        ];
    Future<int> post(List<Map> l) async => (await call('POST', '/journal',
            token: admin, body: {'entry_date': '2026-10-03', 'description': 'يدوي', 'lines': l}))
        .$1;
    expect(await post(lines(100, 100)), 200);
    expect(await post(lines(100, 90)), 400);
    expect(await post(lines(100, 100).sublist(0, 1)), 400);
    expect(
        (await call('POST', '/accounts/transfer',
                token: admin,
                body: {'from_account_id': a1, 'to_account_id': a1, 'amount': 5, 'entry_date': '2026-10-03'}))
            .$1,
        400);
    expect(
        (await call('POST', '/accounts/transfer',
                token: admin,
                body: {'from_account_id': a1, 'to_account_id': a2, 'amount': 5, 'entry_date': '2026-10-03'}))
            .$1,
        200);
  });


  Future<(int, Uint8List)> callBytes(String path, {String? token}) async {
    final res = await app(Request('GET', Uri.parse('http://localhost$path'),
        headers: {if (token != null) 'authorization': 'Bearer $token'}));
    final bb = BytesBuilder();
    await for (final chunk in res.read()) {
      bb.add(chunk);
    }
    return (res.statusCode, bb.toBytes());
  }

  group('التقارير', () {
    test('PDF لكل تقرير', () async {
      for (final k in ['members', 'subscriptions', 'aids', 'treasury', 'vouchers']) {
        final (s, b) = await callBytes('/reports/$k/pdf', token: admin);
        expect(s, 200, reason: k);
        expect(String.fromCharCodes(b.take(4)), '%PDF', reason: k);
      }
    });

    test('Excel صالح يحمل البيانات والإجماليات', () async {
      final (s, b) = await callBytes('/reports/treasury/excel', token: admin);
      expect(s, 200);
      expect(String.fromCharCodes(b.take(2)), 'PK'); // xlsx = zip
      final book = Excel.decodeBytes(b);
      final sheet = book.tables.values.first;
      final header = sheet.rows.first.map((c) => c?.value.toString()).toList();
      expect(header, containsAll(['التاريخ', 'النوع', 'المبلغ']));
      // صف الإجماليات الأخير: صافي الخزينة بالمحلية (250000 + ما سُجّل سابقاً)
      expect(sheet.rows.length, greaterThan(2));
      expect(sheet.rows.last.first?.value.toString(), contains('صافي الخزينة'));
    });

    test('تقرير/صيغة غير صالحين، والمشاهد يقرأ التقارير فقط', () async {
      expect((await callBytes('/reports/nope/pdf', token: admin)).$1, 404);
      expect((await callBytes('/reports/members/doc', token: admin)).$1, 400);
      final v = await login('v1', 'Viewer@1234');
      expect((await callBytes('/reports/members/pdf', token: v)).$1, 200);
    });
  });

  test('مطابقة البنك: كشف، فرق، مطابقة، ومنع التكرار', () async {
    final (_, accs) = await call('GET', '/accounts', token: admin);
    final bank = (accs as List).firstWhere(
        (a) => a['is_postable'] != false && (a['is_bank'] == true || a['is_cash'] == true));
    final bid = bank['id'];
    final (_, other) = await call('GET', '/accounts', token: admin);
    final b2 = other.firstWhere((a) => a['id'] != bid && a['is_postable'] != false);
    // قيد: مدين البنك 500 / دائن حساب آخر
    final (js, _) = await call('POST', '/journal', token: admin, body: {
      'entry_date': '2026-10-03', 'description': 'إيداع',
      'lines': [
        {'account_id': bid, 'debit': 500, 'credit': 0},
        {'account_id': b2['id'], 'debit': 0, 'credit': 500},
      ]
    });
    expect(js, 200);

    var (_, rec) = await call('GET', '/accounts/$bid/reconciliation', token: admin);
    final ledger = (rec['ledger_balance'] as num).toDouble();
    expect(ledger, greaterThanOrEqualTo(500));
    expect(rec['lines'], isEmpty);
    expect((rec['difference'] as num).toDouble(), ledger);

    expect(
        (await call('POST', '/accounts/$bid/statement-lines',
                token: admin, body: {'line_date': 'bad', 'description': 'x', 'amount': 5}))
            .$1,
        400);
    expect(
        (await call('POST', '/accounts/$bid/statement-lines', token: admin, body: {
          'line_date': '2026-10-03', 'description': 'إيداع بنكي', 'amount': 500, 'external_ref': 'R1'
        }))
            .$1,
        200);
    (_, rec) = await call('GET', '/accounts/$bid/reconciliation', token: admin);
    expect(rec['statement_sum'], 500);
    expect((rec['difference'] as num).toDouble(), ledger - 500);
    final lineId = (rec['lines'] as List).first['id'];

    final (_, un) = await call('GET', '/accounts/$bid/unmatched-journal-lines', token: admin);
    final target = (un as List).firstWhere((u) => u['description'] == 'إيداع');
    // سطر قيد من حساب آخر لا يُقبل
    expect(
        (await call('POST', '/accounts/$bid/statement-lines/$lineId/match',
                token: admin, body: {'journal_line_id': 'ghost'}))
            .$1,
        404);
    expect(
        (await call('POST', '/accounts/$bid/statement-lines/$lineId/match',
                token: admin, body: {'journal_line_id': target['journal_line_id']}))
            .$1,
        200);
    // لا مطابقة مزدوجة
    expect(
        (await call('POST', '/accounts/$bid/statement-lines/$lineId/match',
                token: admin, body: {'journal_line_id': target['journal_line_id']}))
            .$1,
        400);
    final (_, un2) = await call('GET', '/accounts/$bid/unmatched-journal-lines', token: admin);
    expect((un2 as List).any((u) => u['journal_line_id'] == target['journal_line_id']), isFalse);
    expect((await call('GET', '/accounts/ghost/reconciliation', token: admin)).$1, 404);
  });

  group('الجلسات', () {
    Future<Map> loginFull(String u, String p) async {
      final (s, r) = await call('POST', '/auth/login', body: {'username': u, 'password': p});
      expect(s, 200, reason: '$r');
      return r as Map;
    }

    test('الخروج يُبطل توكن الوصول فوراً', () async {
      final r = await loginFull('admin', 'Admin@12345');
      expect((await call('GET', '/auth/me', token: r['access_token'])).$1, 200);
      await call('POST', '/auth/logout', body: {'refresh_token': r['refresh_token']});
      expect((await call('GET', '/auth/me', token: r['access_token'])).$1, 401);
      expect((await call('POST', '/auth/refresh', body: {'refresh_token': r['refresh_token']})).$1, 401);
    });

    test('تدوير التجديد، وإعادة استخدام توكن قديم تُنهي كل الجلسات', () async {
      final a = await loginFull('admin', 'Admin@12345');
      final (s, b) = await call('POST', '/auth/refresh', body: {'refresh_token': a['refresh_token']});
      expect(s, 200);
      // الجديد يعمل
      expect((await call('GET', '/auth/me', token: b['access_token'])).$1, 200);
      // القديم مُدوَّر: استخدامه ثانية = سرقة محتملة
      expect((await call('POST', '/auth/refresh', body: {'refresh_token': a['refresh_token']})).$1, 401);
      // ... فتنتهي حتى الجلسة الجديدة
      expect((await call('GET', '/auth/me', token: b['access_token'])).$1, 401);
      expect((await call('POST', '/auth/refresh', body: {'refresh_token': b['refresh_token']})).$1, 401);
    });

    test('logout-all يُنهي كل أجهزة المستخدم فقط', () async {
      final a1 = await loginFull('admin', 'Admin@12345');
      final a2 = await loginFull('admin', 'Admin@12345');
      await call('POST', '/users',
          body: {'username': 'other', 'password': 'Other@12345', 'full_name': 'آخر', 'role': 'viewer'},
          token: a1['access_token']);
      final o = await loginFull('other', 'Other@12345');
      expect((await call('POST', '/auth/logout-all', body: {}, token: a1['access_token'])).$1, 200);
      expect((await call('GET', '/auth/me', token: a1['access_token'])).$1, 401);
      expect((await call('GET', '/auth/me', token: a2['access_token'])).$1, 401);
      expect((await call('GET', '/auth/me', token: o['access_token'])).$1, 200);
      admin = await login('admin', 'Admin@12345'); // للاختبارات التالية
    });

    test('تغيير كلمة المرور يُبقي الجلسة الحالية وينهي الأخرى', () async {
      await call('POST', '/users',
          body: {'username': 'pw', 'password': 'First@12345', 'full_name': 'ك', 'role': 'viewer'},
          token: admin);
      final cur = await loginFull('pw', 'First@12345');
      final other = await loginFull('pw', 'First@12345');
      final (s, _) = await call('POST', '/auth/change-password',
          body: {'old_password': 'First@12345', 'new_password': 'Second@12345'},
          token: cur['access_token']);
      expect(s, 200);
      expect((await call('GET', '/auth/me', token: cur['access_token'])).$1, 200);
      expect((await call('GET', '/auth/me', token: other['access_token'])).$1, 401);
    });

    test('تعطيل المستخدم وتغيير دوره يسريان فوراً', () async {
      final (_, u) = await call('POST', '/users',
          body: {'username': 'tmp', 'password': 'Temp@12345', 'full_name': 'م', 'role': 'viewer'},
          token: admin);
      final t = await loginFull('tmp', 'Temp@12345');
      expect((await call('GET', '/treasury', token: t['access_token'])).$1, 403);
      // ترقية الدور: يسري فوراً دون إعادة دخول
      await call('PUT', '/users/${u['id']}', body: {'role': 'accountant'}, token: admin);
      expect((await call('GET', '/treasury', token: t['access_token'])).$1, 200);
      // تعطيل الحساب: الجلسة القائمة تسقط فوراً
      await call('PUT', '/users/${u['id']}', body: {'is_active': false}, token: admin);
      expect((await call('GET', '/treasury', token: t['access_token'])).$1, 401);
    });
  });
}
