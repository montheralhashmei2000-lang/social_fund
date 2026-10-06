import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:social_fund_dart_server/api/router.dart';
import 'package:social_fund_dart_server/core/pii.dart';
import 'package:social_fund_dart_server/db/database.dart';
import 'package:social_fund_dart_server/db/pii_migration.dart';
import 'package:social_fund_dart_server/db/seed.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late Handler app;
  late String admin;

  Future<(int, dynamic)> call(String method, String path, {Object? body}) async {
    final res = await app(Request(method, Uri.parse('http://localhost$path'),
        body: body == null ? '' : jsonEncode(body),
        headers: {'content-type': 'application/json', 'authorization': 'Bearer $admin'}));
    final text = await res.readAsString();
    return (res.statusCode, text.isEmpty ? null : jsonDecode(text));
  }

  setUp(() async {
    db = AppDatabase.memory();
    await seedDefaultAdmin(db);
    app = buildHandler(db);
    final res = await app(Request('POST', Uri.parse('http://localhost/auth/login'),
        body: jsonEncode({'username': 'admin', 'password': 'Admin@12345'}),
        headers: {'content-type': 'application/json'}));
    admin = jsonDecode(await res.readAsString())['access_token'] as String;
  });
  tearDown(() => db.close());

  Future<Member> rawMember(String id) =>
      (db.select(db.members)..where((t) => t.id.equals(id))).getSingle();

  test('الهوية والهاتف والبريد مشفّرة في القاعدة ومقروءة عبر الواجهة', () async {
    final (s, m) = await call('POST', '/members', body: {
      'name': 'أحمد', 'national_id': '١٢٣٤٥٦٧٨٩', 'phone': '0777123456',
      'email': 'a@b.com', 'monthly_subscription': 500,
    });
    expect(s, 200);
    expect(m['national_id'], '123456789'); // الأرقام العربية مُوحَّدة
    expect(m['phone'], '0777123456');
    expect(m['email'], 'a@b.com');

    final raw = await rawMember(m['id']);
    for (final v in [raw.nationalId, raw.phone, raw.email!]) {
      expect(v.startsWith('v1.'), isTrue);
      expect(v.contains('123456789') || v.contains('0777') || v.contains('a@b.com'), isFalse);
    }
    expect(raw.nationalIdSearch, isNotEmpty);
    expect(raw.name, 'أحمد'); // الاسم يبقى واضحاً (للعرض والبحث)
  });

  test('منع تكرار الهوية (حتى بأرقام عربية) والتحديث', () async {
    await call('POST', '/members',
        body: {'name': 'أ', 'national_id': '555', 'phone': '1'});
    expect((await call('POST', '/members', body: {'name': 'ب', 'national_id': '٥٥٥', 'phone': '2'})).$1, 409);
    final (_, b) = await call('POST', '/members', body: {'name': 'ج', 'national_id': '666', 'phone': '3'});
    // تعديل هوية العضو (كان يُتجاهل سابقاً) إلى رقم مأخوذ → 409، وإلى جديد → ينجح
    expect((await call('PUT', '/members/${b['id']}', body: {'national_id': '555'})).$1, 409);
    final (s, u) = await call('PUT', '/members/${b['id']}', body: {'national_id': '777', 'phone': '999'});
    expect([s, u['national_id'], u['phone']], [200, '777', '999']);
    // حفظ نفس هوية العضو لنفسه مقبول
    expect((await call('PUT', '/members/${b['id']}', body: {'national_id': '777'})).$1, 200);
  });

  test('البحث يعمل رغم التشفير: بالاسم والهوية والجوال والمدينة', () async {
    await call('POST', '/members', body: {'name': 'خالد', 'national_id': '1001', 'phone': '0711', 'city': 'صنعاء'});
    await call('POST', '/members', body: {'name': 'سالم', 'national_id': '2002', 'phone': '0722', 'city': 'عدن'});
    Future<List> find(String q) async => (await call('GET', '/members?search=${Uri.encodeComponent(q)}')).$2 as List;
    expect((await find('خالد')).single['name'], 'خالد');
    expect((await find('2002')).single['name'], 'سالم');
    expect((await find('٢٠٠٢')).single['name'], 'سالم');
    expect((await find('0711')).single['name'], 'خالد');
    expect((await find('عدن')).single['name'], 'سالم');
    expect(await find('غير موجود'), isEmpty);
    expect((await call('GET', '/members')).$2, hasLength(2));
  });

  test('ترحيل البيانات القديمة غير المشفّرة: يشفّر ويفهرس ويُعاد تشغيله بأمان', () async {
    final now = DateTime.now();
    await db.into(db.members).insert(MembersCompanion.insert(
      id: 'legacy-1', name: 'قديم', nationalId: '888', phone: '0733',
      email: const Value('old@x.com'), createdAt: now, updatedAt: now,
    ));
    await db.into(db.beneficiaries).insert(BeneficiariesCompanion.insert(
      id: 'ben-1', fullName: 'مستفيد', nationalId: const Value('999'),
      phone: const Value('0744'), createdAt: now,
    ));

    expect(await PiiMigration.run(db), 2);
    final m = await rawMember('legacy-1');
    expect(m.nationalId.startsWith('v1.'), isTrue);
    expect(m.phone.startsWith('v1.'), isTrue);
    expect(m.email!.startsWith('v1.'), isTrue);
    expect(m.nationalIdSearch, Pii.idHash('888'));
    final ben = await (db.select(db.beneficiaries)..where((t) => t.id.equals('ben-1'))).getSingle();
    expect(ben.nationalId!.startsWith('v1.'), isTrue);
    expect(ben.phone!.startsWith('v1.'), isTrue);
    expect(ben.nationalIdSearch, Pii.idHash('999'));

    // الواجهة تعيد القيم الواضحة، والتكرار يُكتشف عبر الفهرس
    final (_, got) = await call('GET', '/members/legacy-1');
    expect([got['national_id'], got['phone'], got['email']], ['888', '0733', 'old@x.com']);
    expect((await call('POST', '/members', body: {'name': 'م', 'national_id': '888', 'phone': '1'})).$1, 409);
    final (_, bens) = await call('GET', '/beneficiaries');
    expect([bens.single['national_id'], bens.single['phone']], ['999', '0744']);

    // idempotent
    expect(await PiiMigration.run(db), 0);
    expect((await rawMember('legacy-1')).nationalId, m.nationalId);
  });

  test('الشفرة مرتبطة بالسجل: نقلها لسجل آخر لا يُفك', () async {
    final (_, a) = await call('POST', '/members', body: {'name': 'أ', 'national_id': '111', 'phone': '1'});
    final (_, b) = await call('POST', '/members', body: {'name': 'ب', 'national_id': '222', 'phone': '2'});
    final ra = await rawMember(a['id']);
    // نسخ شفرة هوية (أ) إلى سجل (ب): AAD مختلف
    await (db.update(db.members)..where((t) => t.id.equals(b['id'])))
        .write(MembersCompanion(nationalId: Value(ra.nationalId)));
    final (_, got) = await call('GET', '/members/${b['id']}');
    expect(got['national_id'], isNot('111'));
    expect(got['national_id'], contains('تعذّر'));
  });

  test('تقرير الأعضاء يعرض الهوية مفكوكة', () async {
    await call('POST', '/members', body: {'name': 'م', 'national_id': '4242', 'phone': '07'});
    final res = await app(Request('GET', Uri.parse('http://localhost/reports/members/pdf'),
        headers: {'authorization': 'Bearer $admin'}));
    expect(res.statusCode, 200);
  });
}
