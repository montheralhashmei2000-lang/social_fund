import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/rbac.dart';
import '../core/secure_store.dart';
import '../core/server_profiles.dart';
import 'currencies_screen.dart';
import 'servers_screen.dart';
import 'settings_section_screen.dart';
import 'settings_sections.dart';
import '../state/currency_controller.dart';
import '../state/settings_controller.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';
import 'home_shell.dart' show Tabs;

/// الإعدادات — كلاسيكية حديثة: ملف المستخدم، الأمان، التفضيلات، روابط سريعة
/// لكل شاشات النظام، البيانات، الاتصال بالخادم، وعن التطبيق.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool bioOn = false;
  bool bioBusy = false;
  bool pwBusy = false;
  bool backupBusy = false;

  @override
  void initState() {
    super.initState();
    SecureStore.biometricEnabled().then((v) {
      if (mounted) setState(() => bioOn = v);
    });
  }

  void _openTab(int tab) => PushService.openTab.value = tab;

  Future<void> _toggleBio(bool v) async {
    final auth = context.read<AuthController>();
    if (v) {
      setState(() => bioBusy = true);
      final ok = await auth.enableBiometrics(); // تحقق بيومتري حقيقي قبل التفعيل
      if (mounted) {
        setState(() {
          bioOn = ok;
          bioBusy = false;
        });
        uiToast(context,
            ok ? 'تم تفعيل الدخول بالبصمة' : 'تعذّر التحقق البيومتري - لم يتم التفعيل',
            success: ok, error: !ok);
      }
    } else {
      await auth.disableBiometrics();
      if (mounted) setState(() => bioOn = false);
    }
  }

  Future<void> _changePassword() async {
    final old = TextEditingController();
    final nw = TextEditingController();
    final confirm = TextEditingController();
    await uiSheet(
      context,
      title: 'تغيير كلمة المرور',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiField(label: 'كلمة المرور الحالية *', controller: old, obscure: true),
          UiField(label: 'كلمة المرور الجديدة *', controller: nw, obscure: true),
          UiField(label: 'تأكيد كلمة المرور *', controller: confirm, obscure: true),
          UiButton(
            text: pwBusy ? 'جارٍ التغيير…' : 'تغيير كلمة المرور',
            onPressed: pwBusy
                ? null
                : () async {
                    if (nw.text.length < 8) {
                      uiToast(context, 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل', error: true);
                      return;
                    }
                    if (nw.text != confirm.text) {
                      uiToast(context, 'كلمتا المرور غير متطابقتين', error: true);
                      return;
                    }
                    setState(() => pwBusy = true);
                    try {
                      await context.read<AuthController>().changePassword(old.text, nw.text);
                      if (mounted) {
                        Navigator.pop(context);
                        uiToast(context, 'تم التغيير وتم إنهاء الجلسات على جميع الأجهزة', success: true);
                      }
                    } on ApiException catch (e) {
                      if (mounted) uiToast(context, e.message, error: true);
                    } finally {
                      if (mounted) setState(() => pwBusy = false);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _backup() async {
    setState(() => backupBusy = true);
    try {
      final bytes = await ApiService.instance.downloadBackup();
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/social_fund_backup.dump');
      await f.writeAsBytes(bytes);
      if (mounted) {
        await Share.shareXFiles([XFile(f.path)], text: 'نسخة احتياطية من قاعدة البيانات');
      }
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) {
        uiToast(context, 'تعذر تجهيز النسخة الاحتياطية', error: true);
      }
    } finally {
      if (mounted) {
        setState(() => backupBusy = false);
      }
    }
  }

  Future<void> _confirmLogout(bool allDevices) async {
    final ok = await confirmDialog(
      context,
      title: allDevices ? 'إنهاء الجلسات على كل الأجهزة؟' : 'تسجيل الخروج؟',
      message: allDevices
          ? 'سيتم إنهاء جميع الجلسات النشطة لحسابك على كل الأجهزة.'
          : 'ستحتاج تسجيل الدخول من جديد لاستئناف العمل.',
      confirmText: allDevices ? 'إنهاء الكل' : 'خروج',
      danger: true,
      icon: Icons.logout,
    );
    if (!ok || !mounted) return;
    final data = context.read<DataController>();
    final settings = context.read<SettingsController>();
    final currencies = context.read<CurrencyController>();
    await context.read<AuthController>().logout();
    data.clear();
    settings.clear();
    currencies.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final auth = context.watch<AuthController>();
    final theme = context.watch<ThemeController>();
    final connectivity = context.watch<ConnectivityController>();
    final user = auth.user!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== ملف المستخدم =====
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
            borderRadius: const BorderRadius.all(Radius.circular(22)),
            border: Border(top: BorderSide(color: AppColors.light.gold, width: 3)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFDD835), Color(0xFFF9A825)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(user.avatarInitial,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF003300))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(Rbac.label(user.role),
                        style: TextStyle(color: AppColors.light.gold, fontWeight: FontWeight.w700, fontSize: 12)),
                    Text('@${user.username}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ===== الحساب والأمان =====
        _sectionTitle(context, 'الحساب والأمان'),
        _section(context, [
          _row(
            context,
            icon: Icons.fingerprint,
            color: c.goldDark,
            label: 'الدخول بالبصمة',
            sub: auth.biometricsAvailable
                ? (bioOn ? 'مفعّل - تحقق بيومتري حقيقي عند فتح التطبيق' : 'معطّل')
                : 'غير متوفر على هذا الجهاز',
            trailing: Switch(
              value: bioOn,
              activeThumbColor: c.primary,
              onChanged: bioBusy || !auth.biometricsAvailable ? null : _toggleBio,
            ),
          ),
          _row(
            context,
            icon: Icons.lock_outline,
            color: c.primary,
            label: 'تغيير كلمة المرور',
            sub: '8 أحرف على الأقل',
            onTap: _changePassword,
          ),
          _row(
            context,
            icon: Icons.security,
            color: c.info,
            label: 'المصادقة الثنائية (OTP)',
            sub: 'رمز تحقق عبر SMS عند الدخول — يحدد الخادم تفعيلها',
            trailing: Icon(Icons.info_outline, color: c.mu, size: 20),
          ),
          _row(
            context,
            icon: Icons.devices,
            color: c.warn,
            label: 'إنهاء الجلسات على كل الأجهزة',
            sub: 'عند فقدان أو سرقة جهاز',
            onTap: () => _confirmLogout(true),
          ),
        ]),

        // ===== المظهر والتفضيلات =====
        _sectionTitle(context, 'المظهر والخط'),
        _section(context, [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نمط المظهر', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 18), label: Text('تلقائي')),
                      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18), label: Text('فاتح')),
                      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18), label: Text('داكن')),
                    ],
                    selected: {theme.mode},
                    onSelectionChanged: (v) => theme.setMode(v.first),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حجم الخط', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    showSelectedIcon: false,
                    segments: [
                      for (final (label, v) in ThemeController.scales) ButtonSegment(value: v, label: Text(label)),
                    ],
                    selected: {theme.textScale},
                    onSelectionChanged: (v) => theme.setTextScale(v.first),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.surf,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Text(
                    'معاينة: صرف مساعدة طارئة بمبلغ 250,000 للأسرة رقم 1042',
                    style: TextStyle(fontSize: 13.5, color: c.sub, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ]),

        // ===== إعدادات النظام: كل قسم يربط الإعدادات بالشاشات المتأثرة بها =====
        _sectionTitle(context, 'إعدادات النظام'),
        _section(context, [
          for (final sec in settingsSections)
            _row(
              context,
              icon: sec.icon,
              color: sec.color,
              label: sec.title,
              sub: context.watch<SettingsController>().loaded ? sec.summary(context.watch<SettingsController>()) : sec.subtitle,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SettingsSectionScreen(sectionId: sec.id))),
            ),
        ]),

        // ===== الإدارة والصندوق =====
        _sectionTitle(context, 'الصندوق والإدارة'),
        _section(context, [
          if (Rbac.can(user.role, 'settings'))
            _link(context,
                icon: Icons.shield, color: c.ok, label: 'بيانات الصندوق والهوية',
                sub: 'الاسم والشعار وبيانات التواصل الرسمية', tab: Tabs.fundInfo),
          _row(
            context,
            icon: Icons.currency_exchange,
            color: c.ok,
            label: 'العملات وأسعار الصرف',
            sub: Rbac.can(user.role, 'settings')
                ? 'تعريف العملات وتحديث الأسعار'
                : 'اختيار عملة عرض المبالغ على هذا الجهاز',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CurrenciesScreen())),
          ),
          if (Rbac.can(user.role, 'users')) ...[
            _link(context,
                icon: Icons.manage_accounts, color: c.primary, label: 'إدارة المستخدمين والأدوار',
                sub: 'إنشاء الحسابات وصلاحيات كل دور', tab: Tabs.users),
            _link(context,
                icon: Icons.history_edu, color: c.mu, label: 'سجل العمليات (التدقيق)',
                sub: 'كل ما جرى على النظام موثق بالتاريخ والمستخدم', tab: Tabs.audit),
          ],
        ]),

        // ===== البيانات =====
        if (Rbac.can(user.role, 'settings')) ...[
          _sectionTitle(context, 'البيانات'),
          _section(context, [
            _row(
              context,
              icon: Icons.backup,
              color: c.ok,
              label: 'نسخة احتياطية من قاعدة البيانات',
              sub: backupBusy ? 'جارٍ التجهيز…' : 'إنشاء نسخة ومشاركتها',
              onTap: backupBusy ? null : _backup,
            ),
          ]),
        ],

        // ===== الاتصال والخادم =====
        _sectionTitle(context, 'الاتصال والخادم'),
        _section(context, [
          _row(
            context,
            icon: connectivity.online ? Icons.wifi : Icons.wifi_off,
            color: connectivity.online ? c.ok : c.err,
            label: connectivity.online ? 'متصل بالخادم' : 'غير متصل',
            sub: connectivity.online
                ? 'البيانات متزامنة مع الخادم'
                : 'النظام أونلاين فقط - لن تُحفظ التغييرات حتى عودة الاتصال',
          ),
          _row(
            context,
            icon: Icons.dns,
            color: c.primary,
            label: 'الخوادم (${ServerProfiles.active?.name ?? ''})',
            sub: '${AppConfig.baseUrl} · اضغط للتبديل أو الإضافة',
            onTap: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ServersScreen()));
              if (mounted) setState(() {});
            },
          ),
          _row(
            context,
            icon: AppConfig.isSecureBaseUrl ? Icons.verified_user : Icons.gpp_bad,
            color: AppConfig.isSecureBaseUrl ? c.ok : c.err,
            label: AppConfig.isSecureBaseUrl ? 'اتصال مشفر (HTTPS)' : 'تحذير: اتصال غير مشفر',
            sub: AppConfig.isSecureBaseUrl
                ? 'بيانات الدخول والمالية محمية بالنقل المشفر'
                : 'استخدم رابط HTTPS قبل التشغيل في الإنتاج',
          ),
        ]),

        // ===== عن التطبيق =====
        _sectionTitle(context, 'عن التطبيق'),
        _section(context, [
          _row(context,
              icon: Icons.info_outline, color: c.mu, label: 'الإصدار',
              sub: '${AppConfig.appVersion} · نظام أونلاين فقط · البيانات محفوظة على الخادم المشفر'),
        ]),

        UiCard(
          child: _row(
            context,
            icon: Icons.logout,
            color: c.err,
            label: 'تسجيل الخروج',
            sub: 'ستحتاج تسجيل الدخول من جديد',
            danger: true,
            onTap: () => _confirmLogout(false),
          ),
        ),
        Text('الصندوق الاجتماعي التنموي · v${AppConfig.appVersion}',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: c.mu)),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Container(width: 26, height: 3, color: c.gold),
          const SizedBox(width: 8),
          Text(title, style: AppTheme.sectionTitle(c, size: 15)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, List<Widget> rows) {
    final c = App.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: c.gold, width: 2)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }

  Widget _link(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
    required int tab,
  }) {
    final c = App.of(context);
    return InkWell(
      onTap: () => _openTab(tab),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tx)),
                  Text(sub, style: TextStyle(fontSize: 11, color: c.mu)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, size: 18, color: c.mu),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    String? sub,
    Widget? trailing,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final c = App.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (danger ? c.err : color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: danger ? c.err : color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: danger ? c.err : c.tx)),
                  if (sub != null)
                    Text(sub, style: TextStyle(fontSize: 11, color: c.mu)),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_left, size: 18, color: c.mu),
          ],
        ),
      ),
    );
  }
}
