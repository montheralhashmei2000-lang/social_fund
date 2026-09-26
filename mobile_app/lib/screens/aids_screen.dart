import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

const aidTypes = [
  'مساعدة زواج', 'مساعدة وفاة', 'مساعدة مرضية',
  'مساعدة تعليمية', 'مساعدة ولادة', 'مساعدة طارئة',
];

class AidsScreen extends StatefulWidget {
  const AidsScreen({super.key});

  @override
  State<AidsScreen> createState() => _AidsScreenState();
}

class _AidsScreenState extends State<AidsScreen> {
  String filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final role = context.read<AuthController>().user?.role;
    final canReview = Rbac.can(role, 'aids');

    final shown = filter == 'الكل' ? data.aids : data.aids.where((a) => a.status == filter).toList();
    shown.sort((a, b) => b.requestDate.compareTo(a.requestDate));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            for (final (label, status, color) in [
              ('معلق', 'قيد المراجعة', c.warn),
              ('معتمد', 'معتمدة', c.ok),
              ('مصروف', 'مصروفة', c.info),
              ('مرفوض', 'مرفوضة', c.err),
            ])
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => filter = filter == status ? 'الكل' : status),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: filter == status ? color : Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text('${data.aids.where((a) => a.status == status).length}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
                        Text(label, style: TextStyle(fontSize: 10, color: c.sub)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            for (final s in ['الكل', 'قيد المراجعة', 'معتمدة', 'مصروفة', 'مرفوضة'])
              ChoiceChip(
                label: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                selected: filter == s,
                selectedColor: c.primary,
                labelStyle: TextStyle(color: filter == s ? Colors.white : c.sub),
                onSelected: (_) => setState(() => filter = s),
              ),
            if (canReview && data.members.isNotEmpty)
              ActionChip(
                backgroundColor: c.primaryMid,
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    Text('طلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
                onPressed: _add,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          const EmptyState(icon: Icons.volunteer_activism, text: 'لا توجد طلبات مساعدة')
        else
          ...shown.map((a) => _aidCard(context, a, canReview)),
      ],
    );
  }

  Widget _aidCard(BuildContext context, AidRequest a, bool canReview) {
    final c = App.of(context);
    final color = statusColor(a.status, c);
    return UiCard(
      accentRight: color,
      onTap: () => _detail(a),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.memberName,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                    Text('${a.aidType} · ${a.requestDate}',
                        style: TextStyle(fontSize: 12, color: c.sub)),
                  ],
                ),
              ),
              UiBadge(a.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(money(a.amount),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.primary)),
              if (canReview)
                Row(
                  children: [
                    if (a.status == 'قيد المراجعة') ...[
                      _smallBtn(context, 'اعتماد', c.ok, () => _setStatus(a.id, 'معتمدة')),
                      const SizedBox(width: 6),
                      _smallBtn(context, 'رفض', c.err, () => _setStatus(a.id, 'مرفوضة')),
                    ],
                    if (a.status == 'معتمدة')
                      _smallBtn(context, 'صرف', c.info, () => _setStatus(a.id, 'مصروفة')),
                  ],
                ),
            ],
          ),
          if (a.note != null && a.note!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(8)),
              child: Text('📝 ${a.note}',
                  style: TextStyle(fontSize: 12, color: c.mu)),
            ),
        ],
      ),
    );
  }

  Widget _smallBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _setStatus(String id, String status) async {
    final data = context.read<DataController>();
    try {
      await data.setAidStatus(id, status);
      if (mounted) uiToast(context, 'تم تحديث الحالة: $status', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  Future<void> _detail(AidRequest a) async {
    await uiSheet(context, title: 'تفاصيل الطلب', child: _AidDetail(aid: a));
  }

  Future<void> _add() async {
    final data = context.read<DataController>();
    await uiSheet(
      context,
      title: 'طلب مساعدة جديدة',
      child: _AddAidForm(members: data.members, onSubmit: data.createAid),
    );
  }
}

class _AidDetail extends StatelessWidget {
  final AidRequest aid;
  const _AidDetail({required this.aid});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final color = statusColor(aid.status, c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border(right: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            children: [
              Text(money(aid.amount),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: c.tx)),
              const SizedBox(height: 4),
              UiBadge(aid.status),
              const SizedBox(height: 10),
              _row('المستفيد', aid.memberName, c),
              _row('نوع المساعدة', aid.aidType, c),
              _row('تاريخ الطلب', aid.requestDate, c),
              _row('المراجع', aid.reviewerName ?? '—', c),
              if (aid.note != null && aid.note!.isNotEmpty) _row('ملاحظات', aid.note!, c),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String k, String v, AppColors c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: c.sub, fontSize: 13)),
            Flexible(child: Text(v, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.tx))),
          ],
        ),
      );
}

class _AddAidForm extends StatefulWidget {
  final List<Member> members;
  final Future<void> Function({
    required String memberId,
    required String memberName,
    required String aidType,
    required int amount,
    required String requestDate,
    String? note,
  }) onSubmit;

  const _AddAidForm({required this.members, required this.onSubmit});

  @override
  State<_AddAidForm> createState() => _AddAidFormState();
}

class _AddAidFormState extends State<_AddAidForm> {
  String? memberId;
  String type = 'مساعدة زواج';
  final amount = TextEditingController();
  final note = TextEditingController();
  DateTime date = DateTime.now();
  bool busy = false;
  String? err;

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
        UiDropdown<String>(
          label: 'نوع المساعدة',
          value: type,
          items: aidTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => type = v ?? type),
        ),
        UiField(
          label: 'المبلغ (﷼) *',
          controller: amount,
          keyboardType: TextInputType.number,
          icon: Icons.payments_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: Text('تاريخ الطلب: ${date.toIso8601String().split('T').first}',
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
        UiField(label: 'ملاحظات', controller: note, maxLines: 3),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(err!, style: TextStyle(color: c.err, fontSize: 12)),
          ),
        UiButton(
          text: busy ? 'جارٍ الإرسال…' : 'إرسال الطلب',
          onPressed: busy
              ? null
              : () async {
                  final amt = int.tryParse(amount.text.trim()) ?? 0;
                  if (amt <= 0) {
                    setState(() => err = 'أدخل مبلغاً صحيحاً');
                    return;
                  }
                  final member = widget.members.firstWhere((m) => m.id == (memberId ?? widget.members.first.id));
                  setState(() {
                    busy = true;
                    err = null;
                  });
                  try {
                    await widget.onSubmit(
                      memberId: member.id,
                      memberName: member.name,
                      aidType: type,
                      amount: amt,
                      requestDate: date.toIso8601String().split('T').first,
                      note: note.text.trim().isEmpty ? null : note.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      uiToast(context, 'تم إرسال طلب المساعدة', success: true);
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
