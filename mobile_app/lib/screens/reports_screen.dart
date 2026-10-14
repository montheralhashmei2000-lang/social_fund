import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';

/// التقارير والإحصائيات: ملخص عام، الأعضاء، المساعدات، والمالي — بجداول قابلة للفرز
/// مع صفوف إجماليات، وتصدير PDF/Excel من الخادم.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _tabs = ['ملخص', 'الأعضاء', 'المساعدات', 'مالي'];

  String tab = _tabs.first;
  String? exporting;

  static const _reportTitles = {
    'members': 'الأعضاء',
    'subscriptions': 'الاشتراكات',
    'aids': 'طلبات المساعدة',
    'treasury': 'الخزينة',
    'vouchers': 'السندات',
  };

  static const _statuses = ['قيد المراجعة', 'معتمدة', 'مصروفة', 'مرفوضة'];

  Future<void> _export(String key, String fmt) async {
    setState(() => exporting = '$key/$fmt');
    try {
      final bytes = await ApiService.instance.downloadReport(key, fmt);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${key}_report.${fmt == 'pdf' ? 'pdf' : 'xlsx'}');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'تقرير ${_reportTitles[key]} - الصندوق الاجتماعي التنموي');
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر تجهيز ملف التصدير', error: true);
    } finally {
      if (mounted) setState(() => exporting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        FilterChipsBar(options: _tabs, selected: tab, onSelected: (v) => setState(() => tab = v)),
        const SizedBox(height: 14),
        if (tab == 'ملخص') ..._summary(c, data),
        if (tab == 'الأعضاء') ..._members(c, data),
        if (tab == 'المساعدات') ..._aids(c, data),
        if (tab == 'مالي') ..._financial(c, data),
        const SectionHeader('تصدير التقارير', subtitle: 'تُنشأ من الخادم وتُشارك عبر أي تطبيق على الجهاز'),
        _exportCard(c),
      ],
    );
  }

  // ───────── ملخص ─────────
  List<Widget> _summary(AppColors c, DataController data) {
    final net = data.treasuryBalance;
    return [
      Row(
        children: [
          Expanded(
            child: StatTile(
              icon: Icons.account_balance,
              label: 'صافي الخزينة',
              value: money(net),
              color: net >= 0 ? c.primary : c.err,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatTile(
              icon: Icons.receipt_long,
              label: 'الاشتراكات المحصلة',
              value: money(data.collectedSubscriptions),
              color: c.ok,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: StatTile(
              icon: Icons.volunteer_activism,
              label: 'المساعدات المصروفة',
              value: money(data.disbursedAids),
              sub: '${data.aids.where((a) => a.status == 'مصروفة').length} طلب',
              color: c.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatTile(
              icon: Icons.people,
              label: 'مدفوعات الأعضاء',
              value: money(data.memberTotalPaid),
              sub: '${data.members.length} عضو',
              color: c.goldDark,
            ),
          ),
        ],
      ),
    ];
  }

  // ───────── الأعضاء ─────────
  List<Widget> _members(AppColors c, DataController data) {
    final active = data.members.where((m) => m.isActive).length;
    final sorted = [...data.members]..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));
    final totalPaid = data.members.fold<int>(0, (s, m) => s + m.totalPaid);
    final totalDue = data.members.fold<int>(0, (s, m) => s + m.balanceDue);
    return [
      Row(
        children: [
          Expanded(child: StatTile(icon: Icons.check_circle, label: 'نشط', value: '$active', color: c.ok)),
          const SizedBox(width: 10),
          Expanded(
              child: StatTile(
                  icon: Icons.pause_circle, label: 'معلق', value: '${data.members.length - active}', color: c.warn)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(icon: Icons.people, label: 'الإجمالي', value: '${data.members.length}', color: c.primary)),
        ],
      ),
      const SectionHeader('ترتيب الأعضاء بالمدفوعات', subtitle: 'اضغط على عنوان عمود للفرز'),
      AppDataTable(
        columns: const [
          AppColumn('#', minWidth: 40),
          AppColumn('العضو', minWidth: 110, flex: 3),
          AppColumn('مدفوع', numeric: true, minWidth: 80, flex: 2),
          AppColumn('متأخر', numeric: true, minWidth: 80, flex: 2),
        ],
        rows: [
          for (final (i, m) in sorted.indexed)
            AppRow([i + 1, m.name, m.totalPaid, m.balanceDue],
                sortKeys: [i, m.name, m.totalPaid, m.balanceDue],
                tint: m.balanceDue > 0 ? c.warn.withValues(alpha: 0.07) : null),
        ],
        footer: ['', 'الإجمالي', totalPaid, totalDue],
        emptyText: 'لا أعضاء مسجلين',
      ),
    ];
  }

  // ───────── المساعدات ─────────
  List<Widget> _aids(AppColors c, DataController data) {
    final byStatus = {
      for (final st in _statuses) st: data.aids.where((a) => a.status == st).toList(),
    };
    final colors = {'قيد المراجعة': c.warn, 'معتمدة': c.ok, 'مصروفة': c.info, 'مرفوضة': c.err};

    final byType = <String, List<int>>{};
    for (final a in data.aids) {
      final e = byType.putIfAbsent(a.aidType, () => [0, 0]);
      e[0] += 1;
      e[1] += a.amount;
    }
    final typeRows = byType.entries.toList()..sort((a, b) => b.value[1].compareTo(a.value[1]));
    final totalCount = data.aids.length;
    final totalAmount = data.aids.fold<int>(0, (s, a) => s + a.amount);

    return [
      for (var i = 0; i < _statuses.length; i += 2) ...[
        if (i > 0) const SizedBox(height: 10),
        Row(
          children: [
            for (var j = i; j < i + 2; j++) ...[
              if (j > i) const SizedBox(width: 10),
              Expanded(child: _statusTile(c, _statuses[j], byStatus[_statuses[j]]!, colors[_statuses[j]]!)),
            ],
          ],
        ),
      ],
      const SectionHeader('المساعدات حسب النوع'),
      AppDataTable(
        columns: const [
          AppColumn('النوع', minWidth: 110, flex: 3),
          AppColumn('الطلبات', numeric: true, minWidth: 64),
          AppColumn('المبلغ', numeric: true, minWidth: 90, flex: 2),
          AppColumn('النسبة', numeric: true, minWidth: 60),
        ],
        rows: [
          for (final e in typeRows)
            AppRow([
              e.key,
              e.value[0],
              e.value[1],
              totalAmount == 0 ? '0%' : '${(e.value[1] * 100 / totalAmount).toStringAsFixed(0)}%',
            ], sortKeys: [e.key, e.value[0], e.value[1], e.value[1]]),
        ],
        footer: ['الإجمالي', totalCount, totalAmount, totalAmount == 0 ? '' : '100%'],
        emptyText: 'لا طلبات مساعدة',
      ),
    ];
  }

  Widget _statusTile(AppColors c, String st, List aids, Color color) => StatTile(
        icon: switch (st) {
          'قيد المراجعة' => Icons.hourglass_top,
          'معتمدة' => Icons.verified,
          'مصروفة' => Icons.payments,
          _ => Icons.cancel,
        },
        label: st,
        value: '${aids.length}',
        sub: money(aids.fold<int>(0, (s, a) => s + (a.amount as int))),
        color: color,
      );

  // ───────── مالي ─────────
  List<Widget> _financial(AppColors c, DataController data) {
    // تجميع حركات الخزينة شهرياً: وارد/صادر/صافي
    final months = <String, List<int>>{};
    for (final t in data.treasury) {
      final key = t.entryDate.length >= 7 ? t.entryDate.substring(0, 7) : '—';
      final e = months.putIfAbsent(key, () => [0, 0]);
      if (t.isIncome) {
        e[0] += t.amount;
      } else {
        e[1] += t.amount;
      }
    }
    final keys = months.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      Row(
        children: [
          Expanded(child: StatTile(icon: Icons.south_west, label: 'الإيرادات', value: money(data.totalIncome), color: c.ok)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(icon: Icons.north_east, label: 'المصروفات', value: money(data.totalExpense), color: c.err)),
        ],
      ),
      const SizedBox(height: 10),
      StatTile(
        icon: Icons.account_balance,
        label: data.treasuryBalance >= 0 ? 'الفائض (صافي الخزينة)' : 'العجز (صافي الخزينة)',
        value: money(data.treasuryBalance),
        color: data.treasuryBalance >= 0 ? c.primary : c.err,
      ),
      const SectionHeader('حركة الخزينة شهرياً', subtitle: 'الأحدث أولاً'),
      AppDataTable(
        columns: const [
          AppColumn('الشهر', minWidth: 80, flex: 2),
          AppColumn('وارد', numeric: true, minWidth: 80, flex: 2),
          AppColumn('صادر', numeric: true, minWidth: 80, flex: 2),
          AppColumn('الصافي', numeric: true, minWidth: 84, flex: 2),
        ],
        rows: [
          for (final k in keys)
            AppRow([k, months[k]![0], months[k]![1], months[k]![0] - months[k]![1]],
                tint: months[k]![0] - months[k]![1] < 0 ? c.err.withValues(alpha: 0.07) : null),
        ],
        footer: ['الإجمالي', data.totalIncome, data.totalExpense, data.totalIncome - data.totalExpense],
        emptyText: 'لا حركات خزينة',
      ),
    ];
  }

  // ───────── التصدير ─────────
  Widget _exportCard(AppColors c) {
    Widget btn(String key, String fmt, IconData icon, Color color) {
      final busy = exporting == '$key/$fmt';
      return busy
          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : IconButton(
              tooltip: fmt == 'pdf' ? 'PDF' : 'Excel',
              onPressed: exporting == null ? () => _export(key, fmt) : null,
              icon: Icon(icon, color: color),
            );
    }

    return UiCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          for (final (i, e) in _reportTitles.entries.indexed) ...[
            if (i > 0) Divider(height: 1, color: c.border),
            Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.description_outlined, size: 20, color: c.mu),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.tx))),
                btn(e.key, 'pdf', Icons.picture_as_pdf, c.err),
                btn(e.key, 'excel', Icons.grid_on, c.ok),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
