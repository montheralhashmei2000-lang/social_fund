import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  String period = DateTime.now().toIso8601String().substring(0, 7);
  Map<String, dynamic>? report;
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await ApiService.instance.budgetReport(period);
      if (mounted) {
        setState(() {
          report = r;
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

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            UiCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text('موازنة شهر: $period',
                        style: AppTheme.sectionTitle(c, size: 15)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => period = picked.toIso8601String().substring(0, 7));
                        await _load();
                      }
                    },
                    child: const Text('تغيير الشهر'),
                  ),
                ],
              ),
            ),
            if (loading)
              const LoadingView()
            else if (err != null)
              Center(child: Text(err!, style: TextStyle(color: c.err)))
            else ...[
              Row(
                children: [
                  Expanded(child: _total(context, 'المخطط', money2(report!['total_planned'] as double), c.primary)),
                  Expanded(child: _total(context, 'الفعلي', money2(report!['total_actual'] as double), c.info)),
                  Expanded(child: _total(context, 'نسبة الاستهلاك', '${report!['total_usage_pct']}%', c.goldDark)),
                ],
              ),
              const SizedBox(height: 10),
              ...((report!['rows'] as List?) ?? []).map((raw) {
                final r = Map<String, dynamic>.from(raw as Map);
                final pct = ((r['usage_pct'] as num).toDouble()).clamp(0.0, 100.0);
                final over = (r['usage_pct'] as num).toDouble() > 100;
                return UiCard(
                  accentRight: over ? c.err : c.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${r['account_code']} ${r['account_name']}',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.tx))),
                          Text('${money2(r['actual'])} / ${money2(r['planned'])}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                  color: over ? c.err : c.sub)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 8,
                          backgroundColor: c.surf,
                          color: over ? c.err : (pct > 80 ? c.warn : c.ok),
                        ),
                      ),
                      Text('${r['usage_pct']}%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: over ? c.err : c.mu)),
                    ],
                  ),
                );
              }),
              if (((report!['rows'] as List?) ?? []).isEmpty)
                const EmptyState(icon: Icons.fact_check, text: 'لا موازنات مسجلة لهذا الشهر'),
            ],
          ],
        ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            onPressed: _addBudget,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _total(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: App.of(context).mu)),
      ],
    );
  }

  Future<void> _addBudget() async {
    final accounts = await ApiService.instance.accounts();
    if (!mounted) return;
    final expenses = accounts.where((a) => a.type == 'expense' && a.isActive).toList();
    if (expenses.isEmpty) {
      uiToast(context, 'لا حسابات مصروفات — أنشئ شجرة الحسابات أولاً', error: true);
      return;
    }
    String accId = expenses.first.id;
    final planned = TextEditingController();

    await uiSheet(
      context,
      title: 'موازنة شهر $period',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiDropdown<String>(
              label: 'بند المصروف *',
              value: accId,
              items: expenses.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
              onChanged: (v) => setSheet(() => accId = v!),
            ),
            UiField(label: 'المبلغ المخطط *', controller: planned, keyboardType: TextInputType.number),
            UiButton(
              text: 'إنشاء الموازنة',
              onPressed: () async {
                final amt = double.tryParse(planned.text.trim()) ?? 0;
                if (amt <= 0) {
                  uiToast(ctx, 'أدخل مبلغاً صحيحاً', error: true);
                  return;
                }
                try {
                  await ApiService.instance.createBudget({
                    'period': period, 'account_id': accId, 'planned_amount': amt,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                } on ApiException catch (e) {
                  if (ctx.mounted) uiToast(ctx, e.message, error: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
