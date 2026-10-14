import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../state/settings_controller.dart';
import '../widgets/money_input.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';


class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String filter = 'الكل';

  Future<void> _add() async {
    final data = context.read<DataController>();
    await uiSheet(
      context,
      title: 'تسجيل اشتراك',
      accent: AppColors.light.goldDark,
      child: _AddSubForm(members: data.members, onSubmit: (memberId, amount, date, method, money) async {
        await data.createSubscription(
            memberId: memberId, amount: amount, paymentDate: date, method: method, money: money);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final subs = data.subscriptions;
    final total = subs.fold<int>(0, (s, x) => s + x.amount);
    final methods = subs.map((s) => s.method).toSet().toList();
    final shown = filter == 'الكل' ? subs : subs.where((s) => s.method == filter).toList();
    final byMethod = <String, int>{};
    for (final s in subs) {
      byMethod[s.method] = (byMethod[s.method] ?? 0) + s.amount;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFBF6000), Color(0xFFF9A825)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي المحصّل',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
                    Text(money(total),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    Text('${subs.length} معاملة',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: data.members.isEmpty ? null : _add,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFBF6000),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('تسجيل', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            for (final m in ['الكل', ...methods])
              ChoiceChip(
                label: Text(m, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                selected: filter == m,
                selectedColor: const Color(0xFFBF6000),
                labelStyle: TextStyle(color: filter == m ? Colors.white : c.sub),
                onSelected: (_) => setState(() => filter = m),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (byMethod.isNotEmpty)
          Row(
            children: byMethod.entries
                .map((e) => Expanded(
                      child: UiCard(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Column(
                          children: [
                            Text(e.key, style: TextStyle(fontSize: 11, color: c.mu)),
                            Text(money(e.value),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, color: c.primary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        if (shown.isEmpty)
          const EmptyState(icon: Icons.receipt_long, text: 'لا توجد اشتراكات مسجلة بعد')
        else
          ...shown.map((s) => UiCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt, color: c.goldDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.memberName,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.tx)),
                          Text('${s.paymentDate} · ${s.method} · ${s.referenceNo ?? '-'}',
                              style: TextStyle(fontSize: 11, color: c.mu)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+${money(s.amount)}',
                            style: TextStyle(fontWeight: FontWeight.w900, color: c.ok, fontSize: 15)),
                        if (s.origin != null) OriginNote(s.origin!),
                      ],
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}

class _AddSubForm extends StatefulWidget {
  final List<Member> members;
  final Future<void> Function(String memberId, int amount, String date, String method, Map<String, dynamic>? money)
      onSubmit;

  const _AddSubForm({required this.members, required this.onSubmit});

  @override
  State<_AddSubForm> createState() => _AddSubFormState();
}

class _AddSubFormState extends State<_AddSubForm> {
  List<String> get methods => context.read<SettingsController>().paymentMethods;
  String get curMethod => methods.contains(method) ? method! : methods.first;

  String? memberId;
  final moneyCtl = MoneyInputController();
  DateTime date = DateTime.now();
  String? method;
  bool busy = false;
  String? err;

  @override
  void initState() {
    super.initState();
    // قيمة الاشتراك الافتراضية من إعدادات النظام (إن حُدّدت)
    final def = context.read<SettingsController>().defaultSubscription;
    if (def > 0) moneyCtl.text.text = def.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiDropdown<String>(
          label: 'العضو *',
          value: memberId ?? widget.members.first.id,
          items: widget.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
          onChanged: (v) => setState(() => memberId = v),
        ),
        MoneyInput(controller: moneyCtl),
        UiDropdown<String>(
          label: 'طريقة الدفع',
          value: curMethod,
          items: methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => method = v ?? curMethod),
        ),
        Row(
          children: [
            Expanded(
              child: Text('تاريخ الدفع: ${date.toIso8601String().split('T').first}',
                  style: TextStyle(fontSize: 13, color: c.sub)),
            ),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
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
          text: busy ? 'جارٍ الحفظ…' : 'تسجيل الاشتراك',
          variant: 'gold',
          onPressed: busy
              ? null
              : () async {
                  final mv = moneyCtl.read(context);
                  final amt = mv?.local ?? 0;
                  if (amt <= 0) {
                    setState(() => err = 'أدخل مبلغاً صحيحاً أكبر من صفر');
                    return;
                  }
                  setState(() {
                    busy = true;
                    err = null;
                  });
                  try {
                    await widget.onSubmit(
                        memberId ?? widget.members.first.id, amt, date.toIso8601String().split('T').first, curMethod, mv?.extras);
                    if (context.mounted) {
                      Navigator.pop(context);
                      uiToast(context, 'تم تسجيل الاشتراك بنجاح', success: true);
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
