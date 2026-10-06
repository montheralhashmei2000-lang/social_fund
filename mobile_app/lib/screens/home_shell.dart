import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../state/currency_controller.dart';
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

  @override
  void initState() {
    super.initState();
    PushService.openTab.addListener(_onPushTab);
    PushService.foregroundMessage.addListener(_onForeground);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
      // خوادم بلا مسار العملات تُبقي المبالغ بالريال (الخطأ غير حرج داخل load).
      context.read<CurrencyController>().load();
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
    setState(() => selected = PushService.openTab.value);
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

  void _open(int tab) => setState(() => selected = tab);

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
        _TabDef(Tabs.periodic, 'المساعدات الدورية', Icons.autorenew, 'beneficiaries', (_) => const BeneficiariesScreen()),
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
                children: visible.map((t) => t.builder(context)).toList(),
              ),
            ),
          ),
        ],
      ),
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

  const _Header({
    required this.title,
    required this.user,
    required this.pendingAids,
    required this.refreshing,
    this.onBell,
    required this.onAvatar,
    required this.onRefresh,
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
                    Text('الصندوق الاجتماعي التنموي · أونلاين · v${AppConfig.appVersion.split('.')[0]}.0',
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
