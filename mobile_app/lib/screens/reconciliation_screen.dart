import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/ui.dart';

/// المطابقة البنكية: رصيد الدفتر مقابل مجموع الكشف، ومطابقة كل سطر.
class ReconciliationScreen extends StatefulWidget {
  final Account account;
  const ReconciliationScreen({super.key, required this.account});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  Map<String, dynamic>? report;
  List<Map<String, dynamic>> unmatched = [];
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
      final r = await ApiService.instance.reconciliation(widget.account.id);
      final u = await ApiService.instance.unmatchedLines(widget.account.id);
      if (mounted) {
        setState(() {
          report = r;
          unmatched = u;
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
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('مطابقة: ${widget.account.name}',
            style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w700)),
        backgroundColor: c.primaryDark,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.primaryMid,
        icon: const Icon(Icons.post_add, color: Colors.white),
        label: const Text('سطر كشف جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: _addLine,
      ),
      body: loading
          ? const LoadingView()
          : err != null
              ? Center(child: Text(err!, style: TextStyle(color: c.err)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      UiCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _stat(context, 'رصيد الدفتر', money2(report!['ledger_balance'] as double), c.primary),
                            _stat(context, 'مجموع الكشف', money2(report!['statement_sum'] as double), c.info),
                            _stat(context, 'الفرق', money2(report!['difference'] as double),
                                (report!['difference'] as double) == 0 ? c.ok : c.err),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('سطور كشف الحساب البنكي',
                          style: AppTheme.sectionTitle(c, size: 14)),
                      if ((report!['lines'] as List).isEmpty)
                        const EmptyState(icon: Icons.receipt_long, text: 'لا سطور مستوردة بعد — أضف سطور الكشف الورقي')
                      else
                        ...(report!['lines'] as List).map((raw) {
                          final line = Map<String, dynamic>.from(raw as Map);
                          final matched = line['matched_line_id'] != null;
                          final amt = (line['amount'] as num).toDouble();
                          return UiCard(
                            child: Row(
                              children: [
                                Icon(
                                  amt >= 0 ? Icons.south_west : Icons.north_east,
                                  color: amt >= 0 ? c.ok : c.err,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(line['description'].toString(),
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.tx)),
                                      Text('${line['line_date']} · ${line['external_ref'] ?? '-'}',
                                          style: TextStyle(fontSize: 11, color: c.mu)),
                                    ],
                                  ),
                                ),
                                Text(money2(amt.abs()),
                                    style: TextStyle(fontWeight: FontWeight.w800, color: amt >= 0 ? c.ok : c.err)),
                                const SizedBox(width: 6),
                                if (matched)
                                  Icon(Icons.verified, color: c.ok, size: 20)
                                else
                                  TextButton(
                                    onPressed: () => _matchFlow(line['id'].toString()),
                                    child: const Text('مطابقة'),
                                  ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: App.of(context).mu)),
      ],
    );
  }

  Future<void> _addLine() async {
    final desc = TextEditingController();
    final amount = TextEditingController();
    final ext = TextEditingController();
    DateTime d = DateTime.now();

    await uiSheet(
      context,
      title: 'سطر كشف حساب بنكي',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'الوصف *', controller: desc, hint: 'تحويل وارد / رسوم بنكية…'),
            UiField(label: 'المبلغ * (+وارد / -صادر)', controller: amount, keyboardType: TextInputType.number),
            UiField(label: 'مرجع الكشف', controller: ext),
            Row(
              children: [
                Expanded(child: Text('التاريخ: ${d.toIso8601String().split('T').first}',
                    style: TextStyle(fontSize: 13, color: App.of(ctx).sub))),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: ctx, initialDate: d, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (picked != null) setSheet(() => d = picked);
                  },
                  child: const Text('تغيير'),
                ),
              ],
            ),
            UiButton(
              text: 'إضافة',
              onPressed: () async {
                final amt = double.tryParse(amount.text.trim()) ?? 0;
                if (desc.text.trim().isEmpty || amt == 0) {
                  uiToast(ctx, 'أكمل الوصف والمبلغ (غير الصفر)', error: true);
                  return;
                }
                try {
                  await ApiService.instance.addStatementLine(widget.account.id, {
                    'line_date': d.toIso8601String().split('T').first,
                    'description': desc.text.trim(),
                    'amount': amt,
                    'external_ref': ext.text.trim().isEmpty ? null : ext.text.trim(),
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

  Future<void> _matchFlow(String lineId) async {
    if (unmatched.isEmpty) {
      uiToast(context, 'لا سطور قيود غير مطابقة — راجع دفتر القيود', error: true);
      return;
    }
    String? selected = unmatched.first['journal_line_id'] as String;
    await uiSheet(
      context,
      title: 'مطابقة مع سطر قيد',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiDropdown<String>(
              label: 'سطر القيد',
              value: selected,
              items: unmatched
                  .map((u) => DropdownMenuItem(
                        value: u['journal_line_id'] as String,
                        child: Text('${u['entry_no']} · ${u['description']} · ${money2(((u['debit'] as num?)?.toDouble() ?? 0) - ((u['credit'] as num?)?.toDouble() ?? 0))}'),
                      ))
                  .toList(),
              onChanged: (v) => setSheet(() => selected = v),
            ),
            UiButton(
              text: 'تأكيد المطابقة',
              onPressed: () async {
                try {
                  await ApiService.instance.matchStatementLine(widget.account.id, lineId, selected!);
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
