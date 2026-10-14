import 'package:flutter/material.dart';

import '../state/settings_controller.dart';
import 'home_shell.dart' show Tabs;

/// أنواع حقول الإعدادات التي تعرضها [SettingsSectionScreen].
enum SettingKind { list, toggle, number, choice, account, text }

class SettingField {
  final String key;
  final SettingKind kind;
  final String title;
  final String? subtitle;
  final String? hint;
  final String? suffix;
  final Map<String, String>? choices; // قيمة ← عنوان
  const SettingField(this.key, this.kind, this.title,
      {this.subtitle, this.hint, this.suffix, this.choices});
}

/// رابط من قسم الإعدادات إلى شاشة ذات صلة: [tab] تبويب في الشاشة الرئيسية، أو [route] لشاشة مستقلة.
class SettingsLink {
  final String title;
  final String subtitle;
  final IconData icon;
  final int? tab;
  final String? route; // 'currencies' | 'servers'
  final String permission;
  const SettingsLink(this.title, this.subtitle, this.icon, this.permission, {this.tab, this.route});
}

class SettingsSectionDef {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<SettingField> fields;
  final List<SettingsLink> links;
  final String Function(SettingsController s) summary;
  const SettingsSectionDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.fields,
    required this.links,
    required this.summary,
  });
}

const _months = {
  '1': 'يناير', '2': 'فبراير', '3': 'مارس', '4': 'أبريل', '5': 'مايو', '6': 'يونيو',
  '7': 'يوليو', '8': 'أغسطس', '9': 'سبتمبر', '10': 'أكتوبر', '11': 'نوفمبر', '12': 'ديسمبر',
};

final List<SettingsSectionDef> settingsSections = [
  SettingsSectionDef(
    id: 'aids',
    title: 'المساعدات والمستفيدون',
    subtitle: 'أنواع المساعدات، الحد الأعلى، وسياسة الاعتماد',
    icon: Icons.volunteer_activism,
    color: const Color(0xFFE65100),
    fields: const [
      SettingField('aids.types', SettingKind.list, 'أنواع المساعدات',
          subtitle: 'تظهر في قائمة «نوع المساعدة» عند تسجيل أي طلب', hint: 'نوع جديد، مثل: مساعدة إيجار'),
      SettingField('aids.max_amount', SettingKind.number, 'الحد الأعلى للمساعدة الواحدة',
          subtitle: 'بالعملة المحلية — يرفض الخادم أي طلب أعلى منه. 0 = بلا حد', suffix: '﷼'),
      SettingField('aids.require_second_approver', SettingKind.toggle, 'اعتماد مستخدم ثانٍ (فصل المهام)',
          subtitle: 'من سجّل الطلب لا يستطيع اعتماده بنفسه — يراجعه مستخدم آخر'),
    ],
    links: const [
      SettingsLink('طلبات المساعدة', 'الاعتماد والرفض والصرف', Icons.volunteer_activism, 'aids', tab: Tabs.aids),
      SettingsLink('المستفيدون', 'ملفات الأسر والحالات', Icons.groups, 'beneficiaries', tab: Tabs.beneficiaries),
      SettingsLink('المساعدات الدورية', 'الكفالات والمخصصات الشهرية', Icons.autorenew, 'beneficiaries', tab: Tabs.periodic),
      SettingsLink('المساعدات العينية والمخزون', 'الأصناف والكميات', Icons.inventory_2, 'inkind', tab: Tabs.inkind),
    ],
    summary: (s) =>
        '${s.aidTypes.length} نوع · ${s.maxAidAmount > 0 ? 'حد أعلى ${s.maxAidAmount.toInt()}' : 'بلا حد أعلى'}'
        '${s.requireSecondApprover ? ' · اعتماد ثانٍ' : ''}',
  ),
  SettingsSectionDef(
    id: 'payments',
    title: 'الاشتراكات والمدفوعات',
    subtitle: 'قيمة الاشتراك الافتراضية وطرق الدفع',
    icon: Icons.receipt_long,
    color: const Color(0xFF1B5E20),
    fields: const [
      SettingField('subscriptions.default_amount', SettingKind.number, 'قيمة الاشتراك الشهري الافتراضية',
          subtitle: 'تُعبّأ تلقائياً عند تسجيل اشتراك أو عضو جديد. 0 = بلا قيمة افتراضية', suffix: '﷼'),
      SettingField('payments.methods', SettingKind.list, 'طرق الدفع',
          subtitle: 'تظهر في الاشتراكات والسندات', hint: 'طريقة جديدة، مثل: حوالة'),
    ],
    links: const [
      SettingsLink('الأعضاء', 'ملفات الأعضاء واشتراكاتهم', Icons.people, 'members', tab: Tabs.members),
      SettingsLink('الاشتراكات الشهرية', 'التحصيل والمتأخرات', Icons.receipt_long, 'subscriptions', tab: Tabs.subscriptions),
    ],
    summary: (s) =>
        '${s.paymentMethods.length} طرق دفع · اشتراك ${s.defaultSubscription > 0 ? s.defaultSubscription.toInt() : 'غير محدد'}',
  ),
  SettingsSectionDef(
    id: 'vouchers',
    title: 'السندات والخزينة',
    subtitle: 'الترقيم، حساب الخزينة الافتراضي، والسحب فوق الرصيد',
    icon: Icons.approval,
    color: const Color(0xFFBF6000),
    fields: const [
      SettingField('vouchers.default_treasury_account_id', SettingKind.account, 'حساب الخزينة الافتراضي للسندات',
          subtitle: 'يُختار تلقائياً عند إصدار سند (صندوق/بنك/محفظة)'),
      SettingField('vouchers.receipt_prefix', SettingKind.text, 'بادئة ترقيم سند القبض',
          subtitle: 'مثال: REC ← REC-2026-0001', hint: 'REC'),
      SettingField('vouchers.payment_prefix', SettingKind.text, 'بادئة ترقيم سند الصرف',
          subtitle: 'مثال: PAY ← PAY-2026-0001', hint: 'PAY'),
      SettingField('vouchers.block_overdraft', SettingKind.toggle, 'منع الصرف فوق رصيد الحساب',
          subtitle: 'يرفض الخادم سند صرف يتجاوز رصيد حساب الخزينة (فعّله بعد إدخال الأرصدة الافتتاحية)'),
    ],
    links: const [
      SettingsLink('سندات القبض والصرف', 'الإصدار والإلغاء وPDF', Icons.approval, 'vouchers', tab: Tabs.vouchers),
      SettingsLink('الخزينة', 'الإيرادات والمصروفات', Icons.account_balance, 'treasury', tab: Tabs.treasury),
      SettingsLink('الحسابات والبنوك', 'شجرة الحسابات والمطابقة البنكية', Icons.account_balance_wallet, 'accounting',
          tab: Tabs.accounts),
    ],
    summary: (s) =>
        '${s.receiptPrefix}/${s.paymentPrefix}${s.blockOverdraft ? ' · منع الصرف فوق الرصيد' : ''}',
  ),
  SettingsSectionDef(
    id: 'accounting',
    title: 'المحاسبة والعملات',
    subtitle: 'السنة المالية، العملات وأسعار الصرف',
    icon: Icons.menu_book,
    color: const Color(0xFF0D47A1),
    fields: const [
      SettingField('accounting.fiscal_year_start_month', SettingKind.choice, 'بداية السنة المالية',
          subtitle: 'تحدد نطاق «السنة المالية» في القوائم والتقارير', choices: _months),
    ],
    links: const [
      SettingsLink('العملات وأسعار الصرف', 'تعريف العملات وتحديث الأسعار', Icons.currency_exchange, 'settings',
          route: 'currencies'),
      SettingsLink('دفتر القيود', 'القيد المزدوج والتسويات', Icons.menu_book, 'accounting', tab: Tabs.journal),
      SettingsLink('الموازنات', 'التخطيط الشهري للحسابات', Icons.fact_check, 'budgets', tab: Tabs.budgets),
    ],
    summary: (s) => 'تبدأ السنة المالية في ${_months['${s.fiscalStartMonth}']}',
  ),
  SettingsSectionDef(
    id: 'reports',
    title: 'التقارير والقوائم المالية',
    subtitle: 'الفترة الافتراضية للقوائم المالية',
    icon: Icons.assessment,
    color: const Color(0xFF6A1B9A),
    fields: const [
      SettingField('reports.default_period', SettingKind.choice, 'الفترة الافتراضية للتقارير',
          subtitle: 'تُحدَّد تلقائياً عند فتح القوائم المالية',
          choices: {'month': 'الشهر الحالي', 'quarter': 'الربع الحالي', 'year': 'السنة المالية'}),
    ],
    links: const [
      SettingsLink('التقارير والإحصائيات', 'تقارير الأعضاء والمساعدات والخزينة', Icons.assessment, 'reports',
          tab: Tabs.reports),
      SettingsLink('القوائم المالية', 'ميزان المراجعة والدخل والتدفقات', Icons.stacked_line_chart, 'reports',
          tab: Tabs.finReports),
    ],
    summary: (s) =>
        'الفترة الافتراضية: ${{'month': 'الشهر الحالي', 'quarter': 'الربع الحالي', 'year': 'السنة المالية'}[s.reportsPeriod] ?? s.reportsPeriod}',
  ),
];

SettingsSectionDef? settingsSectionById(String id) {
  for (final s in settingsSections) {
    if (s.id == id) return s;
  }
  return null;
}

/// القسم المرتبط بكل شاشة (للأيقونة ⚙ في رأس الشاشة).
String? settingsSectionForTab(int tab) => switch (tab) {
      Tabs.aids || Tabs.beneficiaries || Tabs.periodic || Tabs.inkind => 'aids',
      Tabs.subscriptions || Tabs.members => 'payments',
      Tabs.vouchers || Tabs.treasury || Tabs.accounts => 'vouchers',
      Tabs.journal || Tabs.budgets => 'accounting',
      Tabs.reports || Tabs.finReports => 'reports',
      _ => null,
    };
