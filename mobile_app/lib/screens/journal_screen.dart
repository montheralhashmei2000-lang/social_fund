import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/num_parse.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';

/// دفتر القيود: بحث وفلترة، جدول أسطر لكل قيد (مدين/دائن)، ومحرّر قيد متعدد الأسطر
/// بمؤشر توازن مباشر قبل الترحيل.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const _filters = ['الكل', 'معتمد', 'مسودة'];

  List<Map<String, String>> entryTypes = [];
  String filter = 'الكل';
  String query = '';

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

  bool _matches(JournalEntryModel e) {
    final posted = e.status == 'posted';
    if (filter == 'معتمد' && !posted) return false;
    if (filter == 'مسودة' && posted) return false;
    final q = query.trim();
    if (q.isEmpty) return true;
    final hay = [
      e.entryNo,
      e.description,
      e.entryTypeLabel,
      ...e.lines.map((l) => '${l.accountCode ?? ''} ${l.accountName}'),
    ].join(' ');
    return hay.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();
    final shown = ctl.journal.where(_matches).toList();
    final counts = {
      'الكل': ctl.journal.length,
      'معتمد': ctl.journal.where((e) => e.status == 'posted').length,
      'مسودة': ctl.journal.where((e) => e.status != 'posted').length,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntrySheet,
        icon: const Icon(Icons.add),
        label: const Text('قيد جديد'),
      ),
      body: ctl.loading && ctl.journal.isEmpty
          ? const Padding(padding: EdgeInsets.all(16), child: SkeletonList(count: 4, itemHeight: 120))
          : ctl.journal.isEmpty
              ? EmptyState(
                  icon: Icons.menu_book,
                  text: 'لا قيود بعد',
                  subtitle: 'كل سند أو اشتراك يُنشئ قيداً تلقائياً، ويمكنك تسجيل قيد يدوي',
                  actionText: 'قيد جديد',
                  onAction: _addEntrySheet,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    SearchField(hint: 'ابحث برقم القيد أو الوصف أو الحساب…', onChanged: (v) => setState(() => query = v)),
                    const SizedBox(height: 10),
                    FilterChipsBar(
                      options: _filters,
                      selected: filter,
                      counts: counts,
                      onSelected: (v) => setState(() => filter = v),
                    ),
                    const SizedBox(height: 12),
                    if (shown.isEmpty)
                      const EmptyState(icon: Icons.search_off, text: 'لا نتائج مطابقة')
                    else
                      for (final e in shown) _entryCard(context, e, c),
                  ],
                ),
    );
  }

  Widget _entryCard(BuildContext context, JournalEntryModel e, AppColors c) {
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
              UiBadge(posted ? 'معتمد' : 'مسودة'),
            ],
          ),
          const SizedBox(height: 2),
          Text(e.entryDate, style: TextStyle(fontSize: 11.5, color: c.mu)),
          if (e.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(e.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.sub)),
            ),
          const SizedBox(height: 10),
          _linesTable(e, c),
        ],
      ),
    );
  }

  /// جدول أسطر القيد: الحساب | مدين | دائن + صف إجمالي.
  Widget _linesTable(JournalEntryModel e, AppColors c) {
    final totalDebit = e.lines.fold<double>(0, (s, l) => s + l.debit);
    final totalCredit = e.lines.fold<double>(0, (s, l) => s + l.credit);

    Widget cell(String t, {bool header = false, bool amount = false, Color? color, bool bold = false}) => Text(
          t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: amount ? TextDirection.rtl : null,
          style: amount
              ? AppTheme.amount(c, size: 12.5, color: color ?? c.tx, weight: bold ? FontWeight.w900 : FontWeight.w700)
              : TextStyle(
                  fontSize: header ? 11 : 12.5,
                  fontWeight: header || bold ? FontWeight.w800 : FontWeight.w500,
                  color: header ? c.mu : (color ?? c.sub)),
        );

    Widget row(Widget a, Widget d, Widget cr, {Color? bg, bool top = false}) => Container(
          decoration: BoxDecoration(
            color: bg,
            border: top ? Border(top: BorderSide(color: c.border)) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              Expanded(flex: 5, child: a),
              Expanded(flex: 3, child: Align(alignment: AlignmentDirectional.centerEnd, child: d)),
              Expanded(flex: 3, child: Align(alignment: AlignmentDirectional.centerEnd, child: cr)),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border.withValues(alpha: 0.8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          row(cell('الحساب', header: true), cell('مدين', header: true), cell('دائن', header: true), bg: c.surf),
          for (final l in e.lines)
            row(
              cell('${l.accountCode ?? ''} ${l.accountName}'.trim()),
              l.debit > 0 ? cell(money2(l.debit), amount: true, color: c.ok) : cell('—'),
              l.credit > 0 ? cell(money2(l.credit), amount: true, color: c.info) : cell('—'),
              top: true,
            ),
          row(
            cell('الإجمالي', bold: true, color: c.tx),
            cell(money2(totalDebit), amount: true, bold: true, color: c.ok),
            cell(money2(totalCredit), amount: true, bold: true, color: c.info),
            bg: c.primary.withValues(alpha: c.isDark ? 0.2 : 0.07),
            top: true,
          ),
        ],
      ),
    );
  }

  Future<void> _addEntrySheet() async {
    final ctl = context.read<ExpansionController>();
    List<Account> accounts;
    try {
      accounts = (await ApiService.instance.accounts()).where((a) => a.isActive).toList();
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
      return;
    }
    if (!mounted) return;
    if (accounts.isEmpty) {
      uiToast(context, 'أنشئ شجرة الحسابات أولاً', error: true);
      return;
    }
    await uiSheet(
      context,
      title: 'قيد يومية جديد',
      child: _EntryForm(
        accounts: accounts,
        entryTypes: entryTypes,
        onSubmit: (payload) => ctl.createJournalEntry(payload),
      ),
    );
  }
}

class _LineDraft {
  String? accountId;
  bool isDebit = true;
  final amount = TextEditingController();
  double get value => parseDouble(amount.text) ?? 0;
}

/// محرّر قيد متعدد الأسطر: كل سطر حساب + جانب (مدين/دائن) + مبلغ، مع إجماليات
/// حية. لا يُفعَّل الترحيل إلا إذا تساوى المدين والدائن وكان أكبر من صفر.
class _EntryForm extends StatefulWidget {
  final List<Account> accounts;
  final List<Map<String, String>> entryTypes;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;
  const _EntryForm({required this.accounts, required this.entryTypes, required this.onSubmit});

  @override
  State<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  final desc = TextEditingController();
  DateTime date = DateTime.now();
  late String type = widget.entryTypes.isNotEmpty ? widget.entryTypes.first['key']! : 'adjustment';
  final lines = [_LineDraft(), _LineDraft()..isDebit = false];
  bool busy = false;
  String? err;

  @override
  void dispose() {
    desc.dispose();
    for (final l in lines) {
      l.amount.dispose();
    }
    super.dispose();
  }

  double get totalDebit => lines.where((l) => l.isDebit).fold(0.0, (s, l) => s + l.value);
  double get totalCredit => lines.where((l) => !l.isDebit).fold(0.0, (s, l) => s + l.value);
  bool get linesValid => lines.every((l) => l.accountId != null && l.value > 0);
  bool get balanced => totalDebit > 0 && (totalDebit - totalCredit).abs() < 0.005;

  Future<void> _submit() async {
    setState(() {
      busy = true;
      err = null;
    });
    try {
      await widget.onSubmit({
        'entry_date': date.toIso8601String().split('T').first,
        'description': desc.text.trim().isEmpty ? 'قيد يومية' : desc.text.trim(),
        'entry_type': type,
        'status': 'posted',
        'lines': [
          for (final l in lines)
            {'account_id': l.accountId, 'debit': l.isDebit ? l.value : 0, 'credit': l.isDebit ? 0 : l.value},
        ],
      });
      if (mounted) {
        Navigator.pop(context);
        uiToast(context, 'تم ترحيل القيد', success: true);
      }
    } on ApiException catch (e) {
      setState(() => err = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final diff = totalDebit - totalCredit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.entryTypes.isNotEmpty)
          UiDropdown<String>(
            label: 'نوع القيد',
            value: widget.entryTypes.any((t) => t['key'] == type) ? type : widget.entryTypes.first['key'],
            items: widget.entryTypes.map((t) => DropdownMenuItem(value: t['key'], child: Text(t['label']!))).toList(),
            onChanged: (v) => setState(() => type = v ?? type),
          ),
        UiField(label: 'الوصف', controller: desc, hint: 'بيان القيد'),
        Row(
          children: [
            Expanded(child: Text('التاريخ: ${date.toIso8601String().split('T').first}', style: TextStyle(fontSize: 13, color: c.sub))),
            TextButton(
              onPressed: () async {
                final p = await showDatePicker(
                    context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (p != null) setState(() => date = p);
              },
              child: const Text('تغيير'),
            ),
          ],
        ),
        const SectionHeader('أسطر القيد'),
        for (var i = 0; i < lines.length; i++) _lineEditor(c, i),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => setState(() => lines.add(_LineDraft())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة سطر'),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (balanced ? c.ok : c.warn).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: (balanced ? c.ok : c.warn).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي المدين', style: TextStyle(fontSize: 12.5, color: c.sub)),
                  Text(money2(totalDebit), style: AppTheme.amount(c, color: c.ok)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي الدائن', style: TextStyle(fontSize: 12.5, color: c.sub)),
                  Text(money2(totalCredit), style: AppTheme.amount(c, color: c.info)),
                ],
              ),
              const Divider(height: 16),
              Text(
                balanced ? 'القيد متوازن ✓' : (totalDebit == 0 && totalCredit == 0 ? 'أدخل المبالغ' : 'الفرق ${money2(diff.abs())} — ${diff > 0 ? 'ينقص دائن' : 'ينقص مدين'}'),
                style: TextStyle(fontWeight: FontWeight.w800, color: balanced ? c.ok : c.warn),
              ),
            ],
          ),
        ),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(err!, textAlign: TextAlign.center, style: TextStyle(color: c.err, fontSize: 12.5)),
          ),
        const SizedBox(height: 10),
        UiButton(
          text: busy ? 'جارٍ الترحيل…' : 'ترحيل القيد',
          onPressed: busy || !balanced || !linesValid ? null : _submit,
        ),
      ],
    );
  }

  Widget _lineEditor(AppColors c, int i) {
    final l = lines[i];
    final ids = widget.accounts.map((a) => a.id).toSet();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.surf,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          UiDropdown<String>(
            value: ids.contains(l.accountId) ? l.accountId : null,
            items: [
              for (final a in widget.accounts)
                DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => l.accountId = v),
          ),
          Row(
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: true, label: Text('مدين')),
                  ButtonSegment(value: false, label: Text('دائن')),
                ],
                selected: {l.isDebit},
                onSelectionChanged: (v) => setState(() => l.isDebit = v.first),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: l.amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'المبلغ'),
                ),
              ),
              if (lines.length > 2)
                IconButton(
                  onPressed: () => setState(() {
                    lines.removeAt(i).amount.dispose();
                  }),
                  icon: Icon(Icons.delete_outline, color: c.err),
                  tooltip: 'حذف السطر',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
