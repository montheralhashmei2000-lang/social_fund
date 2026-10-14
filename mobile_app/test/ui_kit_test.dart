// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_fund_app/core/currency.dart';
import 'package:social_fund_app/core/theme.dart';
import 'package:social_fund_app/screens/settings_sections.dart';
import 'package:social_fund_app/state/settings_controller.dart';
import 'package:social_fund_app/widgets/ui_kit.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.theme(AppColors.light),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  setUp(() {
    CurrencyFormat.local = null;
    CurrencyFormat.display = null;
  });

  group('AppDataTable', () {
    const cols = [
      AppColumn('الحساب', minWidth: 100, flex: 2),
      AppColumn('المبلغ', numeric: true, minWidth: 80),
    ];

    testWidgets('يعرض الرأس والصفوف وصف الإجماليات', (tester) async {
      await tester.pumpWidget(_host(AppDataTable(
        columns: cols,
        rows: [
          AppRow(['الصندوق', 1500]),
          AppRow(['البنك', 250]),
        ],
        footer: ['الإجمالي', 1750],
      )));
      expect(find.text('الحساب'), findsOneWidget);
      expect(find.text('الصندوق'), findsOneWidget);
      expect(find.text('1,500'), findsOneWidget);
      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.text('1,750'), findsOneWidget);
    });

    testWidgets('النقر على عنوان عمود يفرز تصاعدياً ثم تنازلياً', (tester) async {
      await tester.pumpWidget(_host(AppDataTable(
        columns: cols,
        rows: [
          AppRow(['ب', 300]),
          AppRow(['أ', 900]),
          AppRow(['ج', 100]),
        ],
      )));
      double y(String t) => tester.getTopLeft(find.text(t)).dy;

      await tester.tap(find.text('المبلغ'));
      await tester.pump();
      expect(y('ج') < y('ب') && y('ب') < y('أ'), isTrue, reason: 'تصاعدي بالمبلغ: 100 ثم 300 ثم 900');

      await tester.tap(find.text('المبلغ'));
      await tester.pump();
      expect(y('أ') < y('ب') && y('ب') < y('ج'), isTrue, reason: 'تنازلي بعد النقر الثاني');
    });

    testWidgets('جدول فارغ يعرض نص الحالة الفارغة', (tester) async {
      await tester.pumpWidget(_host(AppDataTable(columns: cols, rows: const [], emptyText: 'لا حركات')));
      expect(find.text('لا حركات'), findsOneWidget);
    });

    testWidgets('عرض ضيق: تمرير أفقي بدل فيض الأعمدة', (tester) async {
      tester.view.physicalSize = const Size(260, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(AppDataTable(
        columns: const [
          AppColumn('أ', minWidth: 120),
          AppColumn('ب', minWidth: 120),
          AppColumn('ج', minWidth: 120),
        ],
        rows: [AppRow(['1', '2', '3'])],
      )));
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });

  group('confirmDialog', () {
    testWidgets('يعيد true عند التأكيد وfalse عند الإلغاء', (tester) async {
      bool? result;
      await tester.pumpWidget(_host(Builder(
        builder: (ctx) => TextButton(
          onPressed: () async => result = await confirmDialog(ctx, title: 'حذف', message: 'متأكد؟', confirmText: 'نعم'),
          child: const Text('افتح'),
        ),
      )));
      await tester.tap(find.text('افتح'));
      await tester.pumpAndSettle();
      expect(find.text('متأكد؟'), findsOneWidget);
      await tester.tap(find.text('نعم'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('افتح'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('SettingsController', () {
    test('بداية السنة المالية حسب شهر البداية', () {
      final s = SettingsController()..values = {...SettingsController.defaults, 'accounting.fiscal_year_start_month': 7};
      expect(s.fiscalYearStart(DateTime(2026, 10, 7)), '2026-07-01'); // بعد بداية السنة
      expect(s.fiscalYearStart(DateTime(2026, 3, 1)), '2025-07-01'); // قبلها: السنة السابقة
      expect(s.fiscalYearStart(DateTime(2026, 7, 1)), '2026-07-01'); // يوم البداية نفسه
    });

    test('بداية الفترة الافتراضية: شهر/ربع/سنة مالية', () {
      final now = DateTime(2026, 11, 15);
      SettingsController with_(String period, [int month = 1]) => SettingsController()
        ..values = {
          ...SettingsController.defaults,
          'reports.default_period': period,
          'accounting.fiscal_year_start_month': month,
        };
      expect(with_('month').periodStart(now), '2026-11-01');
      expect(with_('quarter').periodStart(now), '2026-10-01');
      expect(with_('year', 4).periodStart(now), '2026-04-01');
    });

    test('القراءات المكتوبة تعيد الافتراضي عند غياب القيمة', () {
      final s = SettingsController()..values = {};
      expect(s.aidTypes, isNotEmpty);
      expect(s.paymentMethods, contains('نقداً'));
      expect(s.requireSecondApprover, isFalse);
      expect(s.maxAidAmount, 0);
      expect(s.fiscalStartMonth, 1);
    });
  });

  group('أقسام الإعدادات', () {
    test('كل حقل في الأقسام له قيمة افتراضية في المتحكم (حماية من انحراف المفاتيح)', () {
      for (final sec in settingsSections) {
        for (final f in sec.fields) {
          expect(SettingsController.defaults.containsKey(f.key), isTrue, reason: '${sec.id}/${f.key}');
        }
      }
    });

    test('معرّفات الأقسام فريدة وكل قسم له ملخص وروابط', () {
      final ids = settingsSections.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
      final ctl = SettingsController();
      for (final sec in settingsSections) {
        expect(sec.summary(ctl), isNotEmpty);
        expect(sec.links, isNotEmpty);
        expect(sec.fields, isNotEmpty);
        expect(settingsSectionById(sec.id), same(sec));
      }
    });

    test('كل شاشة مرتبطة تفتح قسماً موجوداً', () {
      for (final sec in settingsSections) {
        for (final l in sec.links.where((l) => l.tab != null)) {
          final linked = settingsSectionForTab(l.tab!);
          if (linked != null) expect(settingsSectionById(linked), isNotNull);
        }
      }
    });
  });
}
