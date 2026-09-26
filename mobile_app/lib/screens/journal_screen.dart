import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../services/api_service.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, String>> entryTypes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ExpansionController>().loadJournal();
      try {
        final types = await ApiService.instance.journalEntryTypes();
        if (mounted) setState(() => entryTypes = types);
      } on ApiException catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.journal.isEmpty) return const LoadingView();

    return Stack(
      children: [
        if (ctl.journal.isEmpty)
          const Center(child: EmptyState(icon: Icons.menu_book, text: 'لا قيود بعد — سجّل أول قيد متوازن'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: ctl.journal.map((e) => _entryCard(context, e)).toList(),
          ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _addEntrySheet(),
          ),
        ),
      ],
    );
  }

  Widget _entryCard(BuildContext context, JournalEntryModel e) {
    final c = App.of(context);
    final posted = e.status == 'posted';
    return UiCard(
      accentRight: posted ? c.primary : c.warn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${e.entryNo} · ${e.entryTypeLabel}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
              ),
              Text(e.entryDate, style: TextStyle(fontSize: 11, color: c.mu)),
              const SizedBox(width: 8),
              UiBadge(posted ? 'معتمد' : 'مسودة'),
            ],
          ),
          Text(e.description,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: c.sub)),
          const SizedBox(height: 6),
          ...e.lines.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                        child: Text('${l.accountCode ?? ''} ${l.accountName}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: c.sub))),
                    if (l.debit > 0)
                      Text('مدين ${money2(l.debit)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.ok))
                    else
                      Text('دائن ${money2(l.credit)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.info)),
                  ],
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.mu)),
              Text(money2(e.total),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: c.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addEntrySheet() async {
    final ctl = context.read<ExpansionController>();
    final accounts = await ApiService.instance.accounts();
    if (!mounted) return;
    if (accounts.isEmpty) {
      uiToast(context, 'أنشئ شجرة الحسابات أولاً', error: true);
      return;
    }

    final desc = TextEditingController();
    DateTime date = DateTime.now();
    String type = entryTypes.isNotEmpty ? entryTypes.first['key']! : 'adjustment';
    JournalLineModel? debitLine;
    JournalLineModel? creditLine;
    final debitAmt = TextEditingController();
    final creditAmt = TextEditingController();

    await uiSheet(
      context,
      title: 'قيد يومية جديد',
      child: StatefulBuilder(
        builder: (ctx, setSheet) {
          double debitV = double.tryParse(debitAmt.text) ?? 0;
          double creditV = double.tryParse(creditAmt.text) ?? 0;
          final balanced = debitV > 0 && debitV == creditV;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiDropdown<String>(
                label: 'نوع القيد',
                value: type,
                items: entryTypes
                    .map((t) => DropdownMenuItem(value: t['key'], child: Text(t['label']!)))
                    .toList(),
                onChanged: (v) => setSheet(() => type = v ?? type),
              ),
              UiField(label: 'الوصف *', controller: desc),
              Row(
                children: [
                  Expanded(child: Text('التاريخ: ${date.toIso8601String().split('T').first}',
                      style: TextStyle(fontSize: 13, color: App.of(ctx).sub))),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                          context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                      if (picked != null) setSheet(() => date = picked);
                    },
                    child: const Text('تغيير'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: App.of(ctx).surf,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('الجانب المدين', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: App.of(ctx).ok)),
                    UiDropdown<String>(
                      label: 'حساب مدين',
                      value: debitLine?.accountId,
                      items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
                      onChanged: (id) => setSheet(() => debitLine = JournalLineModel(
                          accountId: id!, accountName: '', debit: 0, credit: 0)),
                    ),
                    UiField(label: 'المبلغ المدين *', controller: debitAmt, keyboardType: TextInputType.number,
                        onChanged: (_) => setSheet(() {})),
                    const Divider(),
                    Text('الجانب الدائن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: App.of(ctx).info)),
                    UiDropdown<String>(
                      label: 'حساب دائن',
                      value: creditLine?.accountId,
                      items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
                      onChanged: (id) => setSheet(() => creditLine = JournalLineModel(
                          accountId: id!, accountName: '', debit: 0, credit: 0)),
                    ),
                    UiField(label: 'المبلغ الدائن *', controller: creditAmt, keyboardType: TextInputType.number,
                        onChanged: (_) => setSheet(() {})),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                balanced ? 'القيد متوازن ✓' : 'مدين $debitV ≠ دائن $creditV',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: balanced ? App.of(ctx).ok : App.of(ctx).err),
              ),
              UiButton(
                text: 'ترحيل القيد',
                onPressed: balanced
                    ? () async {
                        try {
                          await ctl.createJournalEntry({
                            'entry_date': date.toIso8601String().split('T').first,
                            'description': desc.text.trim().isEmpty ? 'قيد يومية' : desc.text.trim(),
                            'entry_type': type,
                            'status': 'posted',
                            'lines': [
                              {'account_id': debitLine!.accountId, 'debit': debitV, 'credit': 0},
                              {'account_id': creditLine!.accountId, 'debit': 0, 'credit': creditV},
                            ],
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                        } on ApiException catch (e) {
                          if (ctx.mounted) uiToast(ctx, e.message, error: true);
                        }
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
