import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/currency.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/settings_controller.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';

/// القوائم المالية: ميزان المراجعة، قائمة الدخل، التدفقات النقدية، وتقرير الحملة —
/// بجداول مرتبة قابلة للفرز مع صف إجماليات، وفترات سريعة تتبع إعدادات السنة المالية.
class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  static const _tabs = ['ميزان المراجعة', 'قائمة الدخل', 'التدفقات النقدية', 'تقرير حملة'];
  static const _presets = ['الشهر الحالي', 'الربع الحالي', 'السنة المالية', 'مخصص'];

  int tab = 0; // 0 ميزان مراجعة / 1 قائمة دخل / 2 تدفقات / 3 حملة
  String preset = '';
  late DateTime from;
  DateTime to = DateTime.now();
  Map<String, dynamic>? data;
  List<Campaign> campaigns = [];
  String? campaignId;
  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    from = DateTime.parse(s.periodStart());
    preset = switch (s.reportsPeriod) {
      'year' => 'السنة المالية',
      'quarter' => 'الربع الحالي',
      _ => 'الشهر الحالي',
    };
    _loadCampaigns();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _loadCampaigns() async {
    try {
      final c = await ApiService.instance.campaigns();
      if (mounted) {
        setState(() {
          campaigns = c;
          if (c.isNotEmpty) campaignId = c.first.id;
        });
      }
    } on ApiException catch (_) {}
  }

  static String _d(DateTime d) => d.toIso8601String().split('T').first;

  String get _key => switch (tab) {
        0 => 'trial-balance',
        1 => 'income-statement',
        2 => 'cash-flow',
        _ => 'campaign/$campaignId',
      };

  Map<String, dynamic> get _params => tab == 3 ? {} : {'date_from': _d(from), 'date_to': _d(to)};

  /// قيمة رقمية من JSON سواء جاءت int أو double أو غابت.
  static double _n(Object? v) => (v as num?)?.toDouble() ?? 0;

  Future<void> _load() async {
    if (tab == 3 && campaignId == null) return;
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final r = await ApiService.instance.financialReport(_key, _params);
      if (mounted) setState(() => data = r);
    } on ApiException catch (e) {
      if (mounted) setState(() => err = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _share(String format) async {
    try {
      final bytes = await ApiService.instance.financialReportBytes(_key, {..._params, 'format': format});
      final dir = await getTemporaryDirectory();
      final ext = format == 'pdf' ? 'pdf' : 'xlsx';
      final f = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.$ext');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)]);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر تجهيز الملف', error: true);
    }
  }

  Future<void> _pickPreset(String p) async {
    final s = context.read<SettingsController>();
    final now = DateTime.now();
    switch (p) {
      case 'الشهر الحالي':
        from = DateTime(now.year, now.month, 1);
        to = now;
      case 'الربع الحالي':
        from = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
        to = now;
      case 'السنة المالية':
        from = DateTime.parse(s.fiscalYearStart());
        to = now;
      default:
        final r = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: DateTimeRange(start: from, end: to),
        );
        if (r == null) return;
        from = r.start;
        to = r.end;
    }
    setState(() => preset = p);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: FilterChipsBar(
            options: _tabs,
            selected: _tabs[tab],
            onSelected: (v) {
              setState(() {
                tab = _tabs.indexOf(v);
                data = null;
              });
              _load();
            },
          ),
        ),
        if (tab != 3)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChipsBar(options: _presets, selected: preset, onSelected: _pickPreset),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('الفترة: من ${_d(from)} إلى ${_d(to)}', style: TextStyle(fontSize: 12, color: c.sub)),
                ),
              ],
            ),
          ),
        if (tab == 3 && campaigns.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: UiDropdown<String>(
              label: 'اختر الحملة',
              value: campaignId,
              items: campaigns.map((x) => DropdownMenuItem(value: x.id, child: Text(x.name))).toList(),
              onChanged: (v) {
                setState(() => campaignId = v);
                _load();
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(child: Text(_currencyCaption(), style: TextStyle(fontSize: 11.5, color: c.mu))),
              TextButton.icon(
                onPressed: data == null ? null : () => _share('pdf'),
                icon: Icon(Icons.picture_as_pdf, size: 18, color: c.err),
                label: const Text('PDF'),
              ),
              TextButton.icon(
                onPressed: data == null ? null : () => _share('excel'),
                icon: Icon(Icons.grid_on, size: 18, color: c.ok),
                label: const Text('Excel'),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Padding(padding: EdgeInsets.all(16), child: SkeletonList(count: 4, itemHeight: 70))
              : err != null
                  ? ErrorState(message: err!, onRetry: _load)
                  : data == null
                      ? const EmptyState(icon: Icons.stacked_line_chart, text: 'اختر تقريراً لعرضه')
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: _renderReport(context, data!),
                        ),
        ),
      ],
    );
  }

  String _currencyCaption() {
    final cur = CurrencyFormat.display ?? CurrencyFormat.local;
    return cur == null ? 'المبالغ بالعملة المحلية' : 'المبالغ بـ ${cur.nameAr}';
  }

  List<Widget> _renderReport(BuildContext context, Map<String, dynamic> d) {
    final c = App.of(context);
    final widgets = <Widget>[];

    if (tab == 0) {
      final rows = ((d['rows'] as List?) ?? const []).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      final balanced = d['balanced'] == true;
      widgets.add(_kpis([
        _Kpi('إجمالي مدين', money2(_n(d['total_debit'])), c.ok),
        _Kpi('إجمالي دائن', money2(_n(d['total_credit'])), c.info),
        _Kpi('التوازن', balanced ? 'متوازن ✓' : 'غير متوازن!', balanced ? c.ok : c.err),
      ]));
      widgets.add(AppDataTable(
        columns: const [
          AppColumn('الرمز', minWidth: 54),
          AppColumn('الحساب', minWidth: 112, flex: 3),
          AppColumn('مدين', numeric: true, minWidth: 86, flex: 2),
          AppColumn('دائن', numeric: true, minWidth: 86, flex: 2),
        ],
        rows: [
          for (final r in rows)
            AppRow([r['code'], r['account'], _n(r['debit']), _n(r['credit'])],
                sortKeys: [r['code']?.toString(), r['account']?.toString(), _n(r['debit']), _n(r['credit'])]),
        ],
        footer: ['', 'الإجمالي', _n(d['total_debit']), _n(d['total_credit'])],
        emptyText: 'لا توجد حركات في هذه الفترة',
      ));
    } else if (tab == 1) {
      final income = ((d['income'] as List?) ?? const []).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      final expenses = ((d['expenses'] as List?) ?? const []).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      final net = _n(d['net']);
      widgets.add(_kpis([
        _Kpi('الإيرادات', money2(_n(d['total_income'])), c.ok),
        _Kpi('المصروفات', money2(_n(d['total_expense'])), c.err),
        _Kpi(net >= 0 ? 'الفائض' : 'العجز', money2(net.abs()), net >= 0 ? c.primary : c.err),
      ]));
      widgets.add(const SectionHeader('الإيرادات'));
      widgets.add(_amountTable(income, 'إجمالي الإيرادات', _n(d['total_income'])));
      widgets.add(const SectionHeader('المصروفات'));
      widgets.add(_amountTable(expenses, 'إجمالي المصروفات', _n(d['total_expense'])));
    } else if (tab == 2) {
      final rows = ((d['rows'] as List?) ?? const []).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      double sum(String k) => rows.fold(0.0, (s, r) => s + _n(r[k]));
      widgets.add(_kpis([
        _Kpi('إجمالي الوارد', money2(sum('inflow')), c.ok),
        _Kpi('إجمالي الصادر', money2(sum('outflow')), c.err),
        _Kpi('الرصيد الختامي', money2(sum('closing')), c.primary),
      ]));
      widgets.add(AppDataTable(
        columns: const [
          AppColumn('الحساب', minWidth: 140, flex: 3),
          AppColumn('افتتاحي', numeric: true, minWidth: 92, flex: 2),
          AppColumn('وارد', numeric: true, minWidth: 92, flex: 2),
          AppColumn('صادر', numeric: true, minWidth: 92, flex: 2),
          AppColumn('ختامي', numeric: true, minWidth: 96, flex: 2),
        ],
        rows: [
          for (final r in rows)
            AppRow([r['account'], _n(r['opening']), _n(r['inflow']), _n(r['outflow']), _n(r['closing'])]),
        ],
        footer: ['الإجمالي', sum('opening'), sum('inflow'), sum('outflow'), sum('closing')],
        emptyText: 'لا توجد حركات نقدية في هذه الفترة',
      ));
    } else {
      final goal = _n(d['goal']), raised = _n(d['raised']), spent = _n(d['spent']);
      final percent = _n(d['percent']);
      widgets.add(UiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('نسبة الإنجاز', style: AppTheme.sectionTitle(c, size: 14))),
                Text('${percent.toStringAsFixed(percent == percent.roundToDouble() ? 0 : 1)}%',
                    style: AppTheme.amount(c, size: 20, color: c.goldDark)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: (percent / 100).clamp(0.0, 1.0), minHeight: 10, color: c.gold),
            ),
          ],
        ),
      ));
      widgets.add(_kpis([
        _Kpi('الهدف', money2(goal), c.sub),
        _Kpi('المجموع', money2(raised), c.ok),
        _Kpi('المصروف', money2(spent), c.err),
      ]));
    }
    return widgets;
  }

  Widget _amountTable(List<Map<String, dynamic>> rows, String totalLabel, double total) => AppDataTable(
        columns: const [
          AppColumn('الحساب', minWidth: 150, flex: 3),
          AppColumn('المبلغ', numeric: true, minWidth: 100, flex: 2),
        ],
        rows: [for (final r in rows) AppRow([r['account'], _n(r['amount'])])],
        footer: [totalLabel, total],
        emptyText: 'لا توجد بنود',
      );

  Widget _kpis(List<_Kpi> items) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: items[i].color.withValues(alpha: c.isDark ? 0.18 : 0.09),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(items[i].value, style: AppTheme.amount(c, size: 15, color: items[i].color)),
                    ),
                    const SizedBox(height: 3),
                    Text(items[i].label, style: TextStyle(fontSize: 11, color: c.sub, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final Color color;
  const _Kpi(this.label, this.value, this.color);
}
