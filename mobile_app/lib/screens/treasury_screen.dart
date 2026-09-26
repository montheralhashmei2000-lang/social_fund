import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

const catsIn = ['اشتراكات', 'تبرعات', 'غرامات', 'أخرى'];
const catsEx = ['مساعدات', 'إدارة', 'صيانة', 'أخرى'];

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  String tab = 'all';

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final role = context.read<AuthController>().user?.role;
    final canCreate = Rbac.can(role, 'treasury');

    final income = data.totalIncome;
    final expense = data.totalExpense;
    final balance = data.treasuryBalance;
    final shown = tab == 'all'
        ? data.treasury
        : data.treasury.where((t) => t.type == (tab == 'income' ? 'إيراد' : 'مصروف')).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('صافي الخزينة',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
                  Text(money(balance),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: balance >= 0 ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _box(context, 'إجمالي الإيرادات', money(income), const Color(0xFF69F0AE)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _box(context, 'إجمالي المصروفات', money(expense), const Color(0xFFFF8A80)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        for (final (id, label) in [('all', 'الكل'), ('income', 'إيرادات'), ('expense', 'مصروفات')])
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => tab = id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: tab == id ? c.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: tab == id ? Colors.white : c.mu)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (canCreate) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 44,
                    child: FilledButton(
                      onPressed: _add,
                      style: FilledButton.styleFrom(
                          backgroundColor: c.primaryMid,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (shown.isEmpty)
              const EmptyState(icon: Icons.account_balance, text: 'لا توجد معاملات')
            else
              ...shown.map((t) => _entryCard(context, t)),
          ],
        ),
      ],
    );
  }

  Widget _box(BuildContext context, String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: valueColor)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _entryCard(BuildContext context, TreasuryEntry t) {
    final c = App.of(context);
    final isIncome = t.isIncome;
    final color = isIncome ? c.ok : c.err;
    return UiCard(
      accentRight: color,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.tx)),
                Text('${t.category} · ${t.entryDate} · ${t.referenceNo ?? '-'}',
                    style: TextStyle(fontSize: 11, color: c.mu)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isIncome ? '+' : '-'}${money(t.amount)}',
                  style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15)),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(t.type, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    await uiSheet(context, title: 'تسجيل معاملة مالية', child: const _TreasuryForm());
  }
}

class _TreasuryForm extends StatefulWidget {
  const _TreasuryForm();

  @override
  State<_TreasuryForm> createState() => _TreasuryFormState();
}

class _TreasuryFormState extends State<_TreasuryForm> {
  String type = 'إيراد';
  String cat = 'اشتراكات';
  final desc = TextEditingController();
  final amount = TextEditingController();
  DateTime date = DateTime.now();
  bool busy = false;
  String? err;

  @override
  void dispose() {
    desc.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final cats = type == 'إيراد' ? catsIn : catsEx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiDropdown<String>(
          label: 'نوع المعاملة',
          value: type,
          items: const [
            DropdownMenuItem(value: 'إيراد', child: Text('إيراد')),
            DropdownMenuItem(value: 'مصروف', child: Text('مصروف')),
          ],
          onChanged: (v) => setState(() {
            type = v ?? 'إيراد';
            cat = (type == 'إيراد' ? catsIn : catsEx).first;
          }),
        ),
        UiDropdown<String>(
          label: 'التصنيف',
          value: cat,
          items: cats.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (v) => setState(() => cat = v ?? cat),
        ),
        UiField(label: 'الوصف *', controller: desc, hint: 'وصف المعاملة'),
        UiField(label: 'المبلغ (﷼) *', controller: amount, keyboardType: TextInputType.number, icon: Icons.payments_outlined),
        Row(
          children: [
            Expanded(
              child: Text('التاريخ: ${date.toIso8601String().split('T').first}',
                  style: TextStyle(fontSize: 13, color: c.sub)),
            ),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                    context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (picked != null) setState(() => date = picked);
              },
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text('اختيار'),
            ),
          ],
        ),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(err!, style: TextStyle(color: c.err, fontSize: 12)),
          ),
        UiButton(
          text: busy ? 'جارٍ الحفظ…' : 'تسجيل المعاملة',
          onPressed: busy
              ? null
              : () async {
                  final amt = int.tryParse(amount.text.trim()) ?? 0;
                  if (desc.text.trim().isEmpty || amt <= 0) {
                    setState(() => err = 'يرجى إدخال الوصف ومبلغ صحيح');
                    return;
                  }
                  setState(() {
                    busy = true;
                    err = null;
                  });
                  try {
                    await context.read<DataController>().createTreasuryEntry(
                          type: type,
                          category: cat,
                          description: desc.text.trim(),
                          amount: amt,
                          entryDate: date.toIso8601String().split('T').first,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      uiToast(context, 'تم تسجيل المعاملة', success: true);
                    }
                  } on ApiException catch (e) {
                    setState(() => err = e.message);
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
        ),
      ],
    );
  }
}
