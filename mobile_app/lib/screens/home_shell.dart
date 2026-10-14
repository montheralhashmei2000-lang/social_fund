import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../state/currency_controller.dart';
import '../state/settings_controller.dart';
import '../widgets/ui.dart';
import 'accounts_screen.dart';
import 'aids_screen.dart';
import 'beneficiaries_screen.dart';
import 'budgets_screen.dart';
import 'campaigns_screen.dart';
import 'dashboard_screen.dart';
import 'donors_screen.dart';
import 'financial_reports_screen.dart';
import 'fund_info_screen.dart';
import 'inkind_screen.dart';
import 'journal_screen.dart';
import 'members_screen.dart';
import 'messages_screen.dart';
import 'reports_screen.dart';
import 'scheduler_screen.dart';
import 'settings_screen.dart';
import 'settings_section_screen.dart';
import 'settings_sections.dart';
import 'subscriptions_screen.dart';
import 'treasury_screen.dart';
import 'users_screen.dart';
import 'vouchers_screen.dart';

class Tabs {
  static const dashboard = 0;
  static const members = 1;
  static const subscriptions = 2;
  static const aids = 3;
  static const treasury = 4;
  static const vouchers = 5;
  static const messages = 6;
  static const scheduler = 7;
  static const reports = 8;
  static const fundInfo = 9;
  static const users = 10;
  static const audit = 11;
  static const settings = 12;
  static const accounts = 13;
  static const journal = 14;
  static const budgets = 15;
  static const finReports = 16;
  static const donors = 17;
  static const campaigns = 18;
  static const beneficiaries = 19;
  static const periodic = 20;
  static const inkind = 21;
}

class _TabDef {
  final int index;
  final String title;
  final IconData icon;
  final String? permission;
  final WidgetBuilder builder;
  const _TabDef(this.index, this.title, this.icon, this.permission, this.builder);
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = Tabs.dashboard;
  bool refreshing = false;

  /// الشاشات التي زارها المستخدم: تُبنى عند أول زيارة فقط (كانت كلها تُبنى دفعة واحدة عند الإقلاع).
  final Set<int> _visited = {Tabs.dashboard};

  @override
  void initState() {
    super.initState();
    PushService.openTab.addListener(_onPushTab);
    PushService.foregroundMessage.addListener(_onForeground);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
      // خوادم بلا مسار العملات تُبقي المبالغ بالريال (الخطأ غير حرج داخل load).
      context.read<CurrencyController>().load();
      context.read<SettingsController>().load();
    });
  }

  @override
  void dispose() {
    PushService.openTab.removeListener(_onPushTab);
    PushService.foregroundMessage.removeListener(_onForeground);
    super.dispose();
  }

  void _onPushTab() {
    if (!mounted) return;
    setState(() {
      selected = PushService.openTab.value;
      _visited.add(selected);
    });
  }

  void _onForeground() {
    final msg = PushService.foregroundMessage.value;
    if (msg != null && mounted) {
      uiToast(context, '${msg['title']} — ${msg['body']}');
      PushService.foregroundMessage.value = null;
    }
  }

  Future<void> refresh() async {
    final auth = context.read<AuthController>();
    final data = context.read<DataController>();
    if (mounted) setState(() => refreshing = true);
    final ok = await data.refreshAll(auth.user?.role);
    if (mounted) setState(() => refreshing = false);
    if (!ok && data.lastError != null && mounted) uiToast(context, data.lastError!, error: true);
  }

  void _open(int tab) => setState(() {
        selected = tab;
        _visited.add(tab);
      });

  /// عناصر الشريط السفلي حسب الصلاحيات: أول أربع شاشات متاحة من القائمة المفضلة + «المزيد».
  static const _navPriority = [Tabs.dashboard, Tabs.aids, Tabs.members, Tabs.vouchers, Tabs.treasury, Tabs.reports];

  List<_TabDef> _navTabs(List<_TabDef> visible) {
    final out = <_TabDef>[];
    for (final idx in _navPriority) {
      final t = visible.where((x) => x.index == idx);
      if (t.isNotEmpty) out.add(t.first);
      if (out.length == 4) break;
    }
    return out;
  }

  Future<void> _openMore(List<_TabDef> visible, int selectedIdx) async {
    final picked = await uiSheet<int>(
      context,
      title: 'كل الأقسام',
      child: _MoreGrid(tabs: visible, sections: _sections, selected: selectedIdx),
    );
    if (picked != null) _open(picked);
  }

  List<_TabDef> _allTabs(AppUser user) => [
        _TabDef(Tabs.dashboard, 'لوحة المعلومات', Icons.dashboard, null, (_) => const DashboardScreen()),
        _TabDef(Tabs.members, 'إدارة الأعضاء', Icons.people, 'members', (_) => const MembersScreen()),
        _TabDef(Tabs.subscriptions, 'الاشتراكات الشهرية', Icons.receipt_long, 'subscriptions', (_) => const SubscriptionsScreen()),
        _TabDef(Tabs.aids, 'طلبات المساعدة', Icons.volunteer_activism, 'aids', (_) => const AidsScreen()),
        _TabDef(Tabs.treasury, 'إدارة الخزينة', Icons.account_balance, 'treasury', (_) => const TreasuryScreen()),
        _TabDef(Tabs.vouchers, 'سندات القبض والصرف', Icons.approval, 'vouchers', (_) => const VouchersScreen()),
        _TabDef(Tabs.scheduler, 'المواعيد والجدول', Icons.event, 'scheduler', (_) => const SchedulerScreen()),
        _TabDef(Tabs.messages, 'الرسائل الداخلية', Icons.mail_outline, null, (_) => const MessagesScreen()),
        _TabDef(Tabs.reports, 'التقارير والإحصائيات', Icons.assessment, 'reports', (_) => const ReportsScreen()),
        // المحاسبة المزدوجة
        _TabDef(Tabs.accounts, 'الحسابات والبنوك', Icons.account_balance_wallet, 'accounting', (_) => const AccountsScreen()),
        _TabDef(Tabs.journal, 'دفتر القيود', Icons.menu_book, 'accounting', (_) => const JournalScreen()),
        _TabDef(Tabs.budgets, 'الموازنات الشهرية', Icons.fact_check, 'budgets', (_) => const BudgetsScreen()),
        _TabDef(Tabs.finReports, 'القوائم المالية', Icons.stacked_line_chart, 'reports', (_) => const FinancialReportsScreen()),
        // الجانب الخيري
        _TabDef(Tabs.donors, 'المانحون والمساهمون', Icons.handshake, 'donors', (_) => const DonorsScreen()),
        _TabDef(Tabs.campaigns, 'حملات التبرعات', Icons.campaign, 'campaigns', (_) => const CampaignsScreen()),
        _TabDef(Tabs.beneficiaries, 'المستفيدون', Icons.groups, 'beneficiaries', (_) => const BeneficiariesScreen()),
        _TabDef(Tabs.periodic, 'المساعدات الدورية', Icons.autorenew, 'beneficiaries', (_) => const BeneficiariesScreen(initialPeriodic: true)),
        _TabDef(Tabs.inkind, 'المساعدات العينية والمخزون', Icons.inventory_2, 'inkind', (_) => const InKindScreen()),
        // الإدارة
        _TabDef(Tabs.fundInfo, 'بيانات الصندوق', Icons.shield, 'settings', (_) => const FundInfoScreen()),
        _TabDef(Tabs.users, 'إدارة المستخدمين', Icons.manage_accounts, 'users', (_) => const UsersScreen()),
        _TabDef(Tabs.audit, 'سجل العمليات', Icons.history_edu, 'users', (_) => const AuditScreen()),
        _TabDef(Tabs.settings, 'الإعدادات', Icons.settings, null, (_) => const SettingsScreen()),
      ];

  static const _sections = [
    ('الرئيسية', [Tabs.dashboard]),
    ('العمليات اليومية', [Tabs.members, Tabs.subscriptions, Tabs.aids, Tabs.treasury, Tabs.vouchers, Tabs.scheduler]),
    ('المحاسبة المزدوجة', [Tabs.accounts, Tabs.journal, Tabs.budgets, Tabs.finReports]),
    ('الجانب الخيري', [Tabs.donors, Tabs.campaigns, Tabs.beneficiaries, Tabs.periodic, Tabs.inkind]),
    ('التواصل والإدارة', [Tabs.messages, Tabs.fundInfo, Tabs.users, Tabs.audit, Tabs.settings]),
  ];

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final auth = context.watch<AuthController>();
    final data = context.watch<DataController>();
    final connectivity = context.watch<ConnectivityController>();
    final user = auth.user!;
    final tabs = _allTabs(user);
    final visible = tabs.where((t) => t.permission == null || Rbac.can(user.role, t.permission!)).toList();
    final current = visible.firstWhere((t) => t.index == selected, orElse: () => visible.first);
    final pendingAids = Rbac.can(user.role, 'aids') ? data.pendingAidsCount : 0;
    // أيقونة الإعدادات في رأس الشاشة تفتح قسم إعداداتها (لمن يملك صلاحية الإعدادات)
    final settingsSection = Rbac.can(user.role, 'settings') ? settingsSectionForTab(current.index) : null;
    final nav = _navTabs(visible);
    final navIndex = nav.indexWhere((t) => t.index == current.index);

    return Scaffold(
      backgroundColor: c.bg,
      drawer: _Drawer(user: user, tabs: visible, sections: _sections, selected: current.index, onSelect: _open),
      body: Column(
        children: [
          _Header(
            title: current.title,
            user: user,
            pendingAids: pendingAids,
            refreshing: refreshing,
            onBell: Rbac.can(user.role, 'aids') ? () => _open(Tabs.aids) : null,
            onAvatar: () => _open(Tabs.settings),
            onRefresh: refresh,
            onSettings: settingsSection == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SettingsSectionScreen(sectionId: settingsSection))),
          ),
          if (!connectivity.online)
            Container(
              width: double.infinity,
              color: c.warn.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 15, color: c.warn),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا يوجد اتصال بالإنترنت - النظام يعمل أونلاين فقط ولا يمكن حفظ التغييرات الآن',
                      style: TextStyle(fontSize: 11.5, color: c.warn, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              color: c.primary,
              onRefresh: refresh,
              child: IndexedStack(
                index: visible.indexOf(current),
                children: [
                  for (final t in visible)
                    _visited.contains(t.index) || t.index == current.index
                        ? t.builder(context)
                        : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: nav.length < 2
          ? null
          : NavigationBar(
              selectedIndex: navIndex >= 0 ? navIndex : nav.length, // خارج الشريط ← «المزيد»
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) => i < nav.length ? _open(nav[i].index) : _openMore(visible, current.index),
              destinations: [
                for (final t in nav)
                  NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.icon),
                    label: _short(t),
                  ),
                const NavigationDestination(
                  icon: Icon(Icons.apps_rounded),
                  selectedIcon: Icon(Icons.apps_rounded),
                  label: 'المزيد',
                ),
              ],
            ),
    );
  }

  /// أسماء قصيرة للشريط السفلي.
  static String _short(_TabDef t) => switch (t.index) {
        Tabs.dashboard => 'الرئيسية',
        Tabs.aids => 'المساعدات',
        Tabs.members => 'الأعضاء',
        Tabs.vouchers => 'السندات',
        Tabs.treasury => 'الخزينة',
        Tabs.reports => 'التقارير',
        _ => t.title,
      };
}

/// شبكة «كل الأقسام»: تعرض كل ما يملك المستخدم صلاحيته مجمّعاً كما في القائمة الجانبية.
class _MoreGrid extends StatelessWidget {
  final List<_TabDef> tabs;
  final List<(String, List<int>)> sections;
  final int selected;
  const _MoreGrid({required this.tabs, required this.sections, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, idxs) in sections)
          if (idxs.any((i) => tabs.any((t) => t.index == i))) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
              child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.goldDark)),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
              children: [
                for (final i in idxs)
                  for (final t in tabs.where((x) => x.index == i))
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context, t.index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: t.index == selected ? c.primary.withValues(alpha: 0.12) : c.surf,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.index == selected ? c.primary : c.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, size: 26, color: t.index == selected ? c.primary : c.sub),
                            const SizedBox(height: 6),
                            Text(t.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.tx, height: 1.25)),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final AppUser user;
  final int pendingAids;
  final bool refreshing;
  final VoidCallback? onBell;
  final VoidCallback onAvatar;
  final VoidCallback onRefresh;
  final VoidCallback? onSettings;

  const _Header({
    required this.title,
    required this.user,
    required this.pendingAids,
    required this.refreshing,
    this.onBell,
    required this.onAvatar,
    required this.onRefresh,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.14)),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الصندوق الاجتماعي التنموي',
                        style: TextStyle(
                            color: AppColors.light.gold,
                            fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    Text(title,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ),
              if (refreshing)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                ),
              if (onSettings != null)
                IconButton(
                  onPressed: onSettings,
                  tooltip: 'إعدادات هذه الشاشة',
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.14)),
                  icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                ),
              Stack(
                children: [
                  IconButton(
                    onPressed: onBell,
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.14)),
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                  ),
                  if (pendingAids > 0)
                    Positioned(
                      top: 2, left: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                        decoration: BoxDecoration(
                            color: c.err, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5)),
                        child: Text('$pendingAids', textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onAvatar,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38, height: 38, alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.light.gold, borderRadius: BorderRadius.circular(12)),
                  child: Text(user.avatarInitial,
                      style: const TextStyle(color: Color(0xFF003300), fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  final AppUser user;
  final List<_TabDef> tabs;
  final List<(String, List<int>)> sections;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Drawer({
    required this.user,
    required this.tabs,
    required this.sections,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Drawer(
      backgroundColor: c.card,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFDD835), Color(0xFFF9A825)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(user.avatarInitial,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF003300))),
                  ),
                  const SizedBox(height: 10),
                  Text(user.fullName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(Rbac.label(user.role),
                      style: TextStyle(color: AppColors.light.gold, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  for (final (sectionTitle, sectionTabs) in sections) ...[
                    if (sectionTabs.any((idx) => tabs.any((t) => t.index == idx)))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                        child: Text(sectionTitle.toUpperCase(),
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800,
                                letterSpacing: 1, color: c.goldDark)),
                      ),
                    for (final idx in sectionTabs)
                      ...tabs.where((t) => t.index == idx).map((t) => ListTile(
                            dense: true,
                            leading: Icon(t.icon, color: selected == t.index ? c.primary : c.mu, size: 20),
                            title: Text(t.title,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: selected == t.index ? FontWeight.w800 : FontWeight.w600,
                                    color: selected == t.index ? c.primary : c.tx)),
                            selected: selected == t.index,
                            selectedTileColor: c.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onTap: () {
                              onSelect(t.index);
                              Navigator.pop(context);
                            },
                          )),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('نظام إدارة الصندوق الاجتماعي التنموي · v${AppConfig.appVersion}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: c.mu)),
            ),
          ],
        ),
      ),
    );
  }
}
