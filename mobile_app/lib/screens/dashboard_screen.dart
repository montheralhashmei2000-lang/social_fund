import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/rbac.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../widgets/charts.dart';
import '../widgets/executive_summary.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const _aidTypeColors = [
    Color(0xFF1B5E20), Color(0xFFB71C1C), Color(0xFFE65100),
    Color(0xFF0D47A1), Color(0xFFF9A825), Color(0xFF9C27B0),
  ];

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final auth = context.watch<AuthController>();
    final role = auth.user?.role;

    final canMembers = Rbac.can(role, 'members');
    final canAids = Rbac.can(role, 'aids');
    final canTreasury = Rbac.can(role, 'treasury');
    final canSubs = Rbac.can(role, 'subscriptions');

    // اتجاه آخر 6 أشهر من معاملات الخزينة
    final now = DateTime.now();
    final buckets = <String, int>{};
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      buckets['${d.year}-${d.month.toString().padLeft(2, '0')}'] = 0;
    }
    for (final t in data.treasury) {
      if (!t.isIncome) continue;
      final key = t.entryDate.length >= 7 ? t.entryDate.substring(0, 7) : '';
      if (buckets.containsKey(key)) buckets[key] = buckets[key]! + t.amount;
    }
    final trend = buckets.entries
        .map((e) => TrendPoint(
              _monthsAr[int.tryParse(e.key.split('-')[1])! - 1],
              e.value,
            ))
        .toList();

    final statusCounts = {
      'قيد المراجعة': data.aids.where((a) => a.status == 'قيد المراجعة').length,
      'معتمدة': data.aids.where((a) => a.status == 'معتمدة').length,
      'مصروفة': data.aids.where((a) => a.status == 'مصروفة').length,
      'مرفوضة': data.aids.where((a) => a.status == 'مرفوضة').length,
    };

    final typeSums = <String, int>{};
    for (final a in data.aids) {
      typeSums[a.aidType] = (typeSums[a.aidType] ?? 0) + a.amount;
    }
    final aidSegs = typeSums.entries
        .toList()
        .asMap()
        .entries
        .map((e) => DonutSegment(e.value.value, _aidTypeColors[e.key % _aidTypeColors.length]))
        .toList();

    final activeMembers = data.members.where((m) => m.isActive).length;
    final suspendedMembers = data.members.where((m) => !m.isActive).length;
    final topPayers = [...data.members]..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('صافي الخزينة الحالي',
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
              Text(money(data.treasuryBalance),
                  style: TextStyle(
                      color: data.treasuryBalance >= 0 ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                      fontSize: 34,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _chip('الإيرادات', money(data.totalIncome)),
                  _chip('المصروفات', money(data.totalExpense)),
                  if (canMembers) _chip('الأعضاء', '${data.members.length} عضو'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const ExecutiveSummaryCard(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpi(context, 'أعضاء نشطون', '$activeMembers', c.ok, Icons.people,
                  sub: suspendedMembers > 0 ? '$suspendedMembers معلق' : 'لا معلقين'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpi(context, 'محصّل الاشتراكات', money(data.collectedSubscriptions), c.gold,
                  Icons.savings, sub: '${data.subscriptions.length} معاملة'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpi(context, 'طلبات قيد المراجعة', '${data.pendingAidsCount}', c.warn,
                  Icons.hourglass_top),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpi(context, 'مساعدات مصروفة', money(data.disbursedAids), c.info,
                  Icons.volunteer_activism),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (canTreasury)
          UiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اتجاه الإيرادات (آخر 6 أشهر)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 12),
                TrendLineChart(points: trend),
              ],
            ),
          ),
        if (canAids)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: UiCard(
                  child: Column(
                    children: [
                      Text('توزيع المساعدات',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: c.tx)),
                      const SizedBox(height: 8),
                      if (aidSegs.isNotEmpty) ...[
                        DonutChart(segments: aidSegs, centerLabel: '${data.aids.length}', centerSub: 'طلب'),
                        const SizedBox(height: 8),
                        ...typeSums.entries.take(4).toList().asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _aidTypeColors[e.key % _aidTypeColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: Text(e.value.key,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 9, color: c.mu))),
                                ],
                              ),
                            )),
                      ] else
                        const EmptyState(icon: Icons.pie_chart, text: 'لا توجد طلبات'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: UiCard(
                  child: Column(
                    children: [
                      Text('حالة الأعضاء',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: c.tx)),
                      const SizedBox(height: 8),
                      DonutChart(
                        segments: [
                          DonutSegment(activeMembers, c.ok),
                          DonutSegment(suspendedMembers, c.warn),
                        ],
                        centerLabel: '${data.members.length}',
                        centerSub: 'عضو',
                      ),
                      const SizedBox(height: 8),
                      _legend('$activeMembers نشط', c.ok, context),
                      _legend('$suspendedMembers معلق', c.warn, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (canAids)
          UiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حالات طلبات المساعدة',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 10),
                ProportionalBarChart(bars: [
                  BarDatum('قيد المراجعة', statusCounts['قيد المراجعة']!, c.warn),
                  BarDatum('معتمدة', statusCounts['معتمدة']!, c.ok),
                  BarDatum('مصروفة', statusCounts['مصروفة']!, c.info),
                  BarDatum('مرفوضة', statusCounts['مرفوضة']!, c.err),
                ]),
              ],
            ),
          ),
        if (canMembers)
          UiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الأعضاء الأكثر مساهمة',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                    GestureDetector(
                      onTap: () => PushService.openTab.value = Tabs.reports,
                      child: Text('التقرير الكامل',
                          style: TextStyle(color: c.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...topPayers.take(5).toList().asMap().entries.map((e) {
                  final m = e.value;
                  return Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: e.key < 3 ? c.gold.withOpacity(0.2) : c.bg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${e.key + 1}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: e.key < 3 ? c.goldDark : c.mu)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(m.name.isNotEmpty ? m.name[0] : '?',
                            style: TextStyle(fontWeight: FontWeight.w800, color: c.primary)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tx))),
                      Text(money(m.totalPaid),
                          style: TextStyle(fontWeight: FontWeight.w900, color: c.primary, fontSize: 13)),
                    ],
                  );
                }),
                if (topPayers.isEmpty) const EmptyState(text: 'لا يوجد أعضاء بعد'),
              ],
            ),
          ),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الوصول السريع',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (canMembers)
                    _quick(context, 'الأعضاء', Icons.people, c.primary, Tabs.members),
                  if (canSubs)
                    _quick(context, 'اشتراكات', Icons.receipt_long, c.goldDark, Tabs.subscriptions),
                  if (canAids) _quick(context, 'مساعدات', Icons.favorite, c.err, Tabs.aids),
                  if (canTreasury) _quick(context, 'الخزينة', Icons.account_balance, c.info, Tabs.treasury),
                  _quick(context, 'الرسائل', Icons.mail_outline, c.primaryMid, Tabs.messages),
                  _quick(context, 'التقارير', Icons.assessment, c.goldDark, Tabs.reports),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.7))),
            Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
      );

  Widget _kpi(BuildContext context, String label, String value, Color color, IconData icon,
      {String? sub}) {
    final c = App.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 11, color: c.mu)),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c.tx)),
          if (sub != null) Text(sub, style: TextStyle(fontSize: 11, color: c.mu)),
        ],
      ),
    );
  }

  Widget _legend(String text, Color color, BuildContext context) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 10, color: App.of(context).mu)),
        ],
      );

  Widget _quick(BuildContext context, String label, IconData icon, Color color, int tab) {
    return GestureDetector(
      onTap: () => PushService.openTab.value = tab,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
