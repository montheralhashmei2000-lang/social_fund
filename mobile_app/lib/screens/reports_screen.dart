import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../services/api_service.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String tab = 'summary';
  String? exporting;

  static const _reportTitles = {
    'members': 'الأعضاء',
    'subscriptions': 'الاشتراكات',
    'aids': 'طلبات المساعدة',
    'treasury': 'الخزينة',
    'vouchers': 'السندات',
  };

  Future<void> _export(String key, String fmt) async {
    setState(() => exporting = '$key/$fmt');
    try {
      final bytes = await ApiService.instance.downloadReport(key, fmt);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${key}_report.$fmt');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'تقرير ${_reportTitles[key]} - الصندوق الاجتماعي التنموي');
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (e) {
      if (mounted) uiToast(context, 'تعذر تجهيز ملف التصدير', error: true);
    } finally {
      if (mounted) setState(() => exporting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();

    const tabs = [('summary', 'ملخص'), ('members', 'الأعضاء'), ('aids', 'المساعدات'), ('financial', 'مالي')];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: tabs
                .map((t) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => tab = t.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: tab == t.$1 ? c.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(t.$2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: tab == t.$1 ? Colors.white : c.mu)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (tab == 'summary') ...[
          _big(context, 'صافي الخزينة', data.treasuryBalance, c.primary),
          _big(context, 'إجمالي الاشتراكات المحصلة', data.collectedSubscriptions, c.ok),
          _big(context, 'المساعدات المصروفة', data.disbursedAids, c.err),
          _big(context, 'إجمالي المدفوعات المسجلة على الأعضاء', data.memberTotalPaid, c.info),
        ],
        if (tab == 'members') ...[
          Row(
            children: [
              Expanded(child: _stat(context, 'نشط', data.members.where((m) => m.isActive).length, c.ok)),
              Expanded(child: _stat(context, 'معلق', data.members.where((m) => !m.isActive).length, c.warn)),
              Expanded(child: _stat(context, 'الإجمالي', data.members.length, c.primary)),
            ],
          ),
          const SizedBox(height: 12),
          UiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ترتيب الأعضاء بالمدفوعات',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 8),
                ...(() {
                  final sorted = [...data.members]..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));
                  return sorted
                      .map((m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(m.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, color: c.tx))),
                                Text(money(m.totalPaid),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800, color: c.primary, fontSize: 13)),
                              ],
                            ),
                          ))
                      .toList();
                })(),
              ],
            ),
          ),
        ],
        if (tab == 'aids') ...[
          Row(
            children: [
              for (final (st, col) in [('قيد المراجعة', c.warn), ('معتمدة', c.ok), ('مصروفة', c.info), ('مرفوضة', c.err)])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(top: BorderSide(color: col, width: 3)),
                    ),
                    child: Column(
                      children: [
                        Text('${data.aids.where((a) => a.status == st).length}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: col)),
                        Text(st, style: TextStyle(fontSize: 10, color: c.sub)),
                        Text(
                          money(data.aids.where((a) => a.status == st).fold<int>(0, (s, a) => s + a.amount)),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: col),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          UiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المساعدات حسب النوع',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                const SizedBox(height: 8),
                ...data.aids.fold<Map<String, List<int>>>({}, (acc, a) {
                  acc.putIfAbsent(a.aidType, () => [0, 0]);
                  acc[a.aidType]![0] += a.amount;
                  acc[a.aidType]![1] += 1;
                  return acc;
                }).entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.key, style: TextStyle(fontSize: 13, color: c.sub))),
                              Text('${e.value[1]} طلب · ${money(e.value[0])}',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: c.primary, fontSize: 12.5)),
                            ],
                          ),
                        )),
              ],
            ),
          ),
        ],
        if (tab == 'financial')
          UiCard(
            child: Column(
              children: [
                _row('إجمالي الإيرادات', money(data.totalIncome), c.ok),
                _row('إجمالي المصروفات', money(data.totalExpense), c.err),
                _row('صافي الخزينة', money(data.treasuryBalance), c.info),
              ],
            ),
          ),
        const SizedBox(height: 6),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تصدير التقارير (PDF / Excel)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
              Text('يُنشأ التقرير من الخادم ويُشارك عبر أي تطبيق مثبت على الجهاز.',
                  style: TextStyle(fontSize: 11, color: c.mu)),
              const SizedBox(height: 8),
              ..._reportTitles.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.value, style: TextStyle(fontSize: 13.5, color: c.tx))),
                        if (exporting == '${e.key}/pdf')
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                            tooltip: 'PDF',
                            onPressed: () => _export(e.key, 'pdf'),
                            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFB71C1C)),
                          ),
                        if (exporting == '${e.key}/excel')
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                            tooltip: 'Excel',
                            onPressed: () => _export(e.key, 'excel'),
                            icon: const Icon(Icons.grid_on, color: Color(0xFF2E7D32)),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _big(BuildContext context, String label, int value, Color color) {
    final c = App.of(context);
    return UiCard(
      accentRight: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: c.sub))),
          Text(money(value), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int n, Color color) {
    final c = App.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        children: [
          Text('$n', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: c.sub)),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: App.of(this as BuildContext).sub)),
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
          ],
        ),
      );
}
