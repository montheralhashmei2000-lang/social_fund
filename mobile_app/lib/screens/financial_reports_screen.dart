import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

/// القوائم المالية الاحترافية: ميزان مراجعة، قائمة دخل، تدفقات نقدية، تقرير حملة.
class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  int tab = 0; // 0 ميزان مراجعة / 1 قائمة دخل / 2 تدفقات / 3 حملة
  DateTime from = DateTime.now().subtract(const Duration(days: 30));
  DateTime to = DateTime.now();
  Map<String, dynamic>? data;
  List<Campaign> campaigns = [];
  String? campaignId;
  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
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

  String get _key => switch (tab) {
        0 => 'trial-balance',
        1 => 'income-statement',
        2 => 'cash-flow',
        _ => 'campaign/$campaignId',
      };

  Map<String, dynamic> get _params => tab == 3
      ? {}
      : {'date_from': from.toIso8601String().split('T').first, 'date_to': to.toIso8601String().split('T').first};

  Future<void> _load() async {
    if (tab == 3 && campaignId == null) return;
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final r = await ApiService.instance.financialReport(_key, _params);
      if (mounted) {
        setState(() {
          data = r;
          loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          err = e.message;
          loading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
            spacing: 6,
            children: [
              for (final (i, label) in ['ميزان المراجعة', 'قائمة الدخل', 'التدفقات النقدية', 'تقرير حملة'].indexed)
                ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  selected: tab == i,
                  selectedColor: c.primary,
                  labelStyle: TextStyle(color: tab == i ? Colors.white : c.sub),
                  onSelected: (_) {
                    setState(() {
                      tab = i;
                      data = null;
                    });
                    _load();
                  },
                ),
            ],
          ),
        ),
        if (tab != 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text('من ${from.toIso8601String().split('T').first} إلى ${to.toIso8601String().split('T').first}',
                      style: TextStyle(fontSize: 12.5, color: c.sub)),
                ),
                TextButton(
                  onPressed: () async {
                    final p = await showDatePicker(context: context, initialDate: from, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (p != null) {
                      setState(() => from = p);
                      await _load();
                    }
                  },
                  child: const Text('البداية'),
                ),
                TextButton(
                  onPressed: () async {
                    final p = await showDatePicker(context: context, initialDate: to, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (p != null) {
                      setState(() => to = p);
                      await _load();
                    }
                  },
                  child: const Text('النهاية'),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: data == null ? null : () => _share('pdf'),
              icon: const Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFFB71C1C)),
              label: const Text('PDF'),
            ),
            TextButton.icon(
              onPressed: data == null ? null : () => _share('excel'),
              icon: const Icon(Icons.grid_on, size: 18, color: Color(0xFF2E7D32)),
              label: const Text('Excel'),
            ),
          ],
        ),
        Expanded(
          child: loading
              ? const LoadingView()
              : err != null
                  ? Center(child: Text(err!, style: TextStyle(color: c.err)))
                  : data == null
                      ? const EmptyState(text: 'اختر تقريراً لعرضه')
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: _renderReport(context, data!),
                        ),
        ),
      ],
    );
  }

  List<Widget> _renderReport(BuildContext context, Map<String, dynamic> d) {
    final c = App.of(context);
    final widgets = <Widget>[];

    if (tab == 0) {
      widgets.add(UiCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _sum(context, 'إجمالي مدين', money2(d['total_debit'] as double), c.ok),
            _sum(context, 'إجمالي دائن', money2(d['total_credit'] as double), c.info),
            _sum(context, 'متوازن', d['balanced'] == true ? 'نعم ✓' : 'لا!', d['balanced'] == true ? c.ok : c.err),
          ],
        ),
      ));
      widgets.addAll(((d['rows'] as List?) ?? []).map((raw) {
        final r = Map<String, dynamic>.from(raw as Map);
        return UiCard(
          child: Row(
            children: [
              SizedBox(width: 42, child: Text(r['code'].toString(), style: TextStyle(fontSize: 12, color: c.mu))),
              Expanded(child: Text(r['account'].toString(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.tx))),
              Text(money2(r['debit'] as double), style: TextStyle(fontSize: 12.5, color: c.ok)),
              const SizedBox(width: 10),
              Text(money2(r['credit'] as double), style: TextStyle(fontSize: 12.5, color: c.info)),
            ],
          ),
        );
      }));
    } else if (tab == 1) {
      widgets.add(UiCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _sum(context, 'الإيرادات', money2(d['total_income'] as double), c.ok),
            _sum(context, 'المصروفات', money2(d['total_expense'] as double), c.err),
            _sum(context, 'الصافي', money2(d['net'] as double), c.primary),
          ],
        ),
      ));
      widgets.add(_group(context, 'الإيرادات', (d['income'] as List?) ?? []));
      widgets.add(_group(context, 'المصروفات', (d['expenses'] as List?) ?? []));
    } else if (tab == 2) {
      widgets.addAll(((d['rows'] as List?) ?? []).map((raw) {
        final r = Map<String, dynamic>.from(raw as Map);
        return UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r['account'].toString(), style: AppTheme.sectionTitle(c, size: 13.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('افتتاحي: ${money2(r['opening'] as double)}', style: TextStyle(fontSize: 11.5, color: c.mu)),
                  Text('وارد: ${money2(r['inflow'] as double)}', style: TextStyle(fontSize: 11.5, color: c.ok)),
                  Text('صادر: ${money2(r['outflow'] as double)}', style: TextStyle(fontSize: 11.5, color: c.err)),
                ],
              ),
              Text('الختامي: ${money2(r['closing'] as double)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: c.primary)),
            ],
          ),
        );
      }));
    } else {
      widgets.add(UiCard(
        child: Column(
          children: [
            _sum(context, 'الهدف', money2(d['goal'] as double), c.mu),
            _sum(context, 'المجموع', money2(d['raised'] as double), c.ok),
            _sum(context, 'المصروف', money2(d['spent'] as double), c.err),
            _sum(context, 'نسبة الإنجاز', '${d['percent']}%', c.goldDark),
          ],
        ),
      ));
    }
    return widgets;
  }

  Widget _sum(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: App.of(context).mu)),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List items) {
    final c = App.of(context);
    if (items.isEmpty) return const SizedBox.shrink();
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sectionTitle(c, size: 14)),
          ...items.map((raw) {
            final r = Map<String, dynamic>.from(raw as Map);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(r['account'].toString(), style: TextStyle(fontSize: 12.5, color: c.sub))),
                  Text(money2(r['amount'] as double),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.tx)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
