// أداة معاينة بصرية: تشغّل التطبيق من مسار البداية الحقيقي مع خادم وهمي وبيانات
// تجريبية، وتحفظ صوراً لكل شاشة. لا تعمل إلا عند ضبط PREVIEW_DIR:
//   $env:PREVIEW_DIR = "C:\temp\shots"; flutter test test/ui_preview_test.dart
// (للاطلاع على التصميم دون جهاز أو محاكٍ؛ الخط في الصور أميري بدل خط النظام).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/api_client.dart';
import 'package:social_fund_app/main.dart';
import 'package:social_fund_app/screens/home_shell.dart';
import 'package:social_fund_app/screens/settings_screen.dart';
import 'package:social_fund_app/services/push_service.dart';
import 'package:social_fund_app/widgets/ui_kit.dart';

final String? kDir = Platform.environment['PREVIEW_DIR'];

class _Fake implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? b, Future<void>? c) async {
    final role = Platform.environment['PREVIEW_ROLE'] ?? 'admin';
    Object body;
    switch (o.path) {
      case '/auth/me':
        body = {'id': 'u1', 'username': 'admin', 'full_name': 'منذر فيصل', 'role': role, 'avatar_initial': 'م'};
      case '/members':
        body = [
          for (final (i, n) in ['أحمد محمد الصالح', 'خالد عبدالله الحميري', 'سالم ناصر العولقي', 'فاطمة علي الشامي', 'يوسف حسن المقطري'].indexed)
            {'id': 'm$i', 'name': n, 'national_id': '1000$i', 'phone': '77700$i', 'city': ['صنعاء', 'عدن', 'تعز', 'إب', 'مأرب'][i],
              'status': i == 3 ? 'معلق' : 'نشط', 'monthly_subscription': 5000, 'total_paid': 60000 - i * 7000, 'balance_due': i * 5000}
        ];
      case '/aids':
        body = [
          for (final (i, s) in ['قيد المراجعة', 'معتمدة', 'مصروفة', 'مرفوضة', 'قيد المراجعة'].indexed)
            {'id': 'a$i', 'member_id': 'm$i', 'member_name': 'أحمد محمد الصالح', 'aid_type': ['مساعدة مرضية', 'مساعدة زواج', 'مساعدة طارئة', 'مساعدة تعليمية', 'مساعدة وفاة'][i],
              'amount': 150000 + i * 25000, 'request_date': '2026-09-${10 + i}', 'status': s, 'note': i == 0 ? 'حالة مستعجلة' : null}
        ];
      case '/subscriptions':
        body = [
          for (var i = 0; i < 6; i++)
            {'id': 's$i', 'member_id': 'm$i', 'member_name': 'خالد عبدالله الحميري', 'amount': 5000, 'payment_date': '2026-09-0${i + 1}', 'period': '2026-09',
              'method': ['نقداً', 'تحويل بنكي', 'محفظة إلكترونية'][i % 3], 'reference_no': 'V-10$i'}
        ];
      case '/treasury':
        body = [
          for (var i = 0; i < 8; i++)
            {'id': 't$i', 'type': i % 3 == 2 ? 'مصروف' : 'إيراد', 'category': i % 3 == 2 ? 'مساعدات' : 'اشتراكات', 'description': i % 3 == 2 ? 'صرف مساعدة طارئة' : 'تحصيل اشتراكات الشهر',
              'amount': 40000 + i * 13000, 'entry_date': '2026-09-${20 + i}', 'reference_no': 'R-$i'}
        ];
      case '/vouchers':
        body = [
          for (var i = 0; i < 4; i++)
            {'id': 'v$i', 'voucher_no': 'V-20$i', 'kind': i.isEven ? 'قبض' : 'صرف', 'member_name': 'سالم ناصر', 'amount': 25000 * (i + 1), 'voucher_date': '2026-09-2$i',
              'method': 'نقداً', 'description': 'سند تجريبي', 'issued_by_name': 'المدير', 'status': i == 3 ? 'ملغي' : 'معتمد'}
        ];
      case '/currencies':
        body = [
          {'code': 'YER', 'name_ar': 'ريال يمني', 'symbol': '﷼', 'decimals': 0, 'rate': 1, 'is_local': true, 'is_default': true, 'is_active': true},
          {'code': 'USD', 'name_ar': 'دولار أمريكي', 'symbol': r'$', 'decimals': 2, 'rate': 2530, 'is_local': false, 'is_default': false, 'is_active': true},
        ];
      case '/campaigns':
        body = [
          {'id': 'c1', 'name': 'كسوة الشتاء', 'description': 'توفير ملابس شتوية للأسر المحتاجة', 'goal_amount': 2000000,
            'raised': 1250000, 'spent': 400000, 'net': 850000, 'percent': 62.5, 'status': 'active'},
          {'id': 'c2', 'name': 'سلة رمضان', 'description': null, 'goal_amount': 1000000,
            'raised': 1000000, 'spent': 1000000, 'net': 0, 'percent': 100, 'status': 'closed'},
        ];
      case '/inkind/items':
        body = [
          {'id': 'k1', 'name': 'سلة غذائية', 'unit': 'سلة', 'quantity': 12, 'reorder_level': 20, 'low_stock': true},
          {'id': 'k2', 'name': 'بطانية', 'unit': 'قطعة', 'quantity': 140, 'reorder_level': 30, 'low_stock': false},
        ];
      case '/beneficiaries':
        body = [
          {'id': 'b1', 'full_name': 'أسرة محمد علي', 'family_size': 6, 'monthly_income': 40000, 'status': 'active'},
          {'id': 'b2', 'full_name': 'أسرة سعيد ناصر', 'family_size': 4, 'monthly_income': 0, 'status': 'suspended'},
        ];
      case '/journal':
        body = [
          {'id': 'j1', 'entry_no': 'JE-000001', 'entry_date': '2026-10-03', 'description': 'تحصيل اشتراكات شهر أكتوبر',
            'entry_type': 'voucher_receipt', 'entry_type_label': 'سند قبض', 'status': 'posted', 'total': 150000,
            'lines': [
              {'account_id': 'ac1', 'account_name': 'الصندوق', 'account_code': '1100', 'debit': 150000, 'credit': 0},
              {'account_id': 'ac4', 'account_name': 'إيرادات الاشتراكات', 'account_code': '4100', 'debit': 0, 'credit': 150000},
            ]},
          {'id': 'j2', 'entry_no': 'JE-000002', 'entry_date': '2026-10-05', 'description': 'صرف مساعدة طارئة',
            'entry_type': 'voucher_payment', 'entry_type_label': 'سند صرف', 'status': 'draft', 'total': 40000,
            'lines': [
              {'account_id': 'ac5', 'account_name': 'مساعدات نقدية', 'account_code': '5100', 'debit': 40000, 'credit': 0},
              {'account_id': 'ac1', 'account_name': 'الصندوق', 'account_code': '1100', 'debit': 0, 'credit': 40000},
            ]},
        ];
      case '/journal/entry-types':
        body = [{'key': 'general', 'label': 'قيد عام'}];
      case '/app-settings':
        body = <String, Object>{};
      case '/accounts':
        body = [
          {'id': 'ac1', 'code': '1100', 'name': 'الصندوق', 'type': 'asset', 'type_label': 'أصول', 'currency': 'YER',
            'is_cash': true, 'is_bank': false, 'is_wallet': false, 'is_active': true, 'balance': 342000},
          {'id': 'ac2', 'code': '1200', 'name': 'بنك الكريمي', 'type': 'asset', 'type_label': 'أصول', 'currency': 'YER',
            'is_cash': false, 'is_bank': true, 'is_wallet': false, 'is_active': true, 'balance': 1200000},
        ];
      case '/fund-settings':
        body = {'name': 'الصندوق الاجتماعي التنموي', 'phone': '01234567', 'address': 'صنعاء'};
      default:
        if (o.path.startsWith('/financial-reports/trial-balance')) {
          body = {
            'total_debit': 513000, 'total_credit': 513000, 'balanced': true,
            'rows': [
              {'code': '1100', 'account': 'الصندوق', 'debit': 342000, 'credit': 0},
              {'code': '1200', 'account': 'بنك الكريمي', 'debit': 171000, 'credit': 0},
              {'code': '4100', 'account': 'إيرادات الاشتراكات', 'debit': 0, 'credit': 313000},
              {'code': '4200', 'account': 'تبرعات ومنح', 'debit': 0, 'credit': 200000},
            ],
          };
        } else if (o.path.startsWith('/financial-reports')) {
          body = <String, Object>{};
        } else {
          body = <Object>[];
        }
    }
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('Roboto', 'assets/fonts/Amiri-Regular.ttf');
    await _loadFont('Amiri', 'assets/fonts/Amiri-Regular.ttf');
    // خط الواجهة (Tajawal) بأوزانه — بدونه تظهر النصوص مربعات في الصور
    final tj = FontLoader('Tajawal');
    for (final w in ['Regular', 'Medium', 'Bold', 'ExtraBold']) {
      final b = File('assets/fonts/Tajawal-$w.ttf').readAsBytesSync();
      tj.addFont(Future.value(ByteData.view(b.buffer)));
    }
    await tj.load();
    final icons = File('C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(icons.readAsBytesSync().buffer)));
      await loader.load();
    }
    // قنوات الإضافات (اتصال الشبكة) تُحاكى حتى لا تفشل في بيئة الاختبار
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (call) async => call.method == 'check' ? ['wifi'] : null);
    messenger.setMockMethodCallHandler(const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
        (call) async => null);
  });

  Future<void> shot(WidgetTester tester, GlobalKey key, String name) async {
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final f = File('$kDir/$name.png')..createSync(recursive: true);
      f.writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  testWidgets('معاينة الشاشات', (tester) async {
    debugDisableShadows = false; // ظلال حقيقية في الصور (الاختبارات ترسمها حدوداً صلبة)
    addTearDown(() => debugDisableShadows = true); // تعيد الحالة الافتراضية (فحص ثوابت الاختبار)
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    FlutterSecureStorage.setMockInitialValues({
      'sf_access_token': 'x', 'sf_refresh_token': 'y',
      if (Platform.environment['PREVIEW_DARK'] == '1') 'sf_dark_mode': '1',
    });
    ApiClient.instance.dio.httpClientAdapter = _Fake();
    await ApiClient.instance.loadStoredTokens();

    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const AppProviders()));
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '01_home');

    final tabs = <(String, int)>[
      ('02_members', Tabs.members),
      ('03_aids', Tabs.aids),
      ('04_treasury', Tabs.treasury),
      ('05_more', -100),
      ('06_subscriptions', Tabs.subscriptions),
      ('07_vouchers', Tabs.vouchers),
      ('08_settings', Tabs.settings),
      ('09_reports', Tabs.reports),
      ('10_currencies_hub', Tabs.finReports),
      ('14_accounts', Tabs.accounts),
      ('15_journal', Tabs.journal),
      ('16_campaigns', Tabs.campaigns),
      ('17_inkind', Tabs.inkind),
      ('18_beneficiaries', Tabs.beneficiaries),
    ];
    for (final (name, tab) in tabs) {
      PushService.openTab.value = tab;
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      final err = tester.takeException();
      // ignore: prefer_interpolation_to_compose_strings
      if (err != null) debugPrint('EXC[' + name + ']: ' + err.toString().split(String.fromCharCode(10)).first);
      await shot(tester, key, name);
    }

    // تبويبات شاشة التقارير
    PushService.openTab.value = Tabs.reports;
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    for (final (n, label) in [('19_reports_members', 'الأعضاء'), ('20_reports_aids', 'المساعدات'), ('21_reports_fin', 'مالي')]) {
      await tester.tap(find.descendant(of: find.byType(FilterChipsBar), matching: find.text(label)).first);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final err = tester.takeException();
      // ignore: prefer_interpolation_to_compose_strings
      if (err != null) debugPrint('EXC[' + n + ']: ' + err.toString().split(String.fromCharCode(10)).first);
      await shot(tester, key, n);
    }

    // شبكة «المزيد» من الشريط السفلي
    PushService.openTab.value = Tabs.dashboard;
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('المزيد'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '12_more_grid');
    await tester.tapAt(const Offset(200, 20)); // إغلاق الورقة بالنقر على الحاجز
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    PushService.openTab.value = Tabs.settings;
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();

    // قسم إعدادات (المساعدات) من مركز الإعدادات
    await tester.dragUntilVisible(
        find.text('المساعدات والمستفيدون'),
        find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first,
        const Offset(0, -300));
    await tester.tap(find.text('المساعدات والمستفيدون'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '13_settings_aids');
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // نموذج إضافة عضو (ورقة سفلية)
    PushService.openTab.value = Tabs.members;
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byIcon(Icons.add).first);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '11_member_sheet');
  }, skip: kDir == null);

  testWidgets('شاشات الدخول', (tester) async {
    debugDisableShadows = false; // ظلال حقيقية في الصور (الاختبارات ترسمها حدوداً صلبة)
    addTearDown(() => debugDisableShadows = true); // تعيد الحالة الافتراضية (فحص ثوابت الاختبار)
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({});
    ApiClient.instance.dio.httpClientAdapter = _Fake();
    await ApiClient.instance.clearTokens();

    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const AppProviders()));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '20_login_splash');
    await tester.tap(find.byType(FilledButton).first);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    tester.takeException();
    await shot(tester, key, '21_login_form');
  }, skip: kDir == null);

}
