import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';

/// المستفيدون + المساعدات الدورية (تبويبان).
class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  bool periodicTab = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>().loadBeneficiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    App.of(context); // ربط البناء بلوحة الألوان (إعادة بناء عند تغيّر الثيم)
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.beneficiaries.isEmpty && ctl.periodicAids.isEmpty) {
      return const LoadingView();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('المستفيدون'), icon: Icon(Icons.groups)),
              ButtonSegment(value: true, label: Text('مساعدات دورية'), icon: Icon(Icons.autorenew)),
            ],
            selected: {periodicTab},
            onSelectionChanged: (s) => setState(() => periodicTab = s.first),
          ),
        ),
        Expanded(
          child: periodicTab ? _periodic(context, ctl) : _beneficiaries(context, ctl),
        ),
      ],
    );
  }

  // ================= المستفيدون =================

  Widget _beneficiaries(BuildContext context, ExpansionController ctl) {
    final c = App.of(context);
    return Stack(
      children: [
        if (ctl.beneficiaries.isEmpty)
          const Center(child: EmptyState(icon: Icons.groups, text: 'لا مستفيدين مسجلين'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: ctl.beneficiaries.map((b) => UiCard(
                  accentRight: b.status == 'active' ? c.primary : c.warn,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(b.fullName.isNotEmpty ? b.fullName[0] : '?',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: c.primary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.fullName,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
                            Text('أسرة من ${b.familySize} · دخل ${money2(b.monthlyIncome)}',
                                style: TextStyle(fontSize: 11.5, color: c.mu)),
                          ],
                        ),
                      ),
                      UiBadge(b.status == 'active' ? 'نشط' : 'معلق'),
                    ],
                  ),
                )).toList(),
          ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _addBeneficiarySheet(),
          ),
        ),
      ],
    );
  }

  Future<void> _addBeneficiarySheet() async {
    final ctl = context.read<ExpansionController>();
    final name = TextEditingController();
    final nid = TextEditingController();
    final phone = TextEditingController();
    final family = TextEditingController(text: '1');
    final income = TextEditingController(text: '0');
    final housing = TextEditingController();
    final caseSummary = TextEditingController();

    await uiSheet(
      context,
      title: 'مستفيد جديد (دراسة حالة)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiField(label: 'الاسم الكامل *', controller: name),
          UiField(label: 'رقم الهوية', controller: nid, keyboardType: TextInputType.number),
          UiField(label: 'الهاتف', controller: phone, keyboardType: TextInputType.phone),
          UiField(label: 'عدد أفراد الأسرة', controller: family, keyboardType: TextInputType.number),
          UiField(label: 'الدخل الشهري', controller: income, keyboardType: TextInputType.number),
          UiField(label: 'السكن (ملك/إيجار…)', controller: housing),
          UiField(label: 'ملخص دراسة الحالة', controller: caseSummary, maxLines: 3),
          UiButton(
            text: 'تسجيل المستفيد',
            onPressed: () async {
              if (name.text.trim().isEmpty) {
                uiToast(context, 'أدخل اسم المستفيد', error: true);
                return;
              }
              try {
                await ctl.createBeneficiary({
                  'full_name': name.text.trim(),
                  'national_id': nid.text.trim().isEmpty ? null : nid.text.trim(),
                  'phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
                  'family_size': int.tryParse(family.text.trim()) ?? 1,
                  'monthly_income': double.tryParse(income.text.trim()) ?? 0,
                  'housing': housing.text.trim().isEmpty ? null : housing.text.trim(),
                  'case_summary': caseSummary.text.trim().isEmpty ? null : caseSummary.text.trim(),
                });
                if (mounted) Navigator.pop(context);
              } on ApiException catch (e) {
                if (mounted) uiToast(context, e.message, error: true);
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= المساعدات الدورية =================

  Widget _periodic(BuildContext context, ExpansionController ctl) {
    final c = App.of(context);
    final due = ctl.periodicAids.where((p) => p.duePeriod != null).toList();
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (due.isNotEmpty) ...[
              UiCard(
                accentRight: c.warn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مستحق الصرف هذا الشهر (${due.length})',
                        style: AppTheme.sectionTitle(c, size: 13)),
                    ...due.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(p.beneficiaryName,
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.tx))),
                              Text(money2(p.monthlyAmount),
                                  style: TextStyle(fontWeight: FontWeight.w900, color: c.goldDark)),
                              TextButton(
                                onPressed: () => _paySheet(p),
                                child: const Text('صرف'),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text('جميع المساعدات الدورية', style: AppTheme.sectionTitle(c, size: 14)),
            ...ctl.periodicAids.map((p) => UiCard(
                  child: Row(
                    children: [
                      Icon(Icons.autorenew, color: p.status == 'active' ? c.ok : c.mu, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.beneficiaryName,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
                            Text('آخر صرف: ${p.lastPaidPeriod ?? 'لم يصرف'}',
                                style: TextStyle(fontSize: 11, color: c.mu)),
                          ],
                        ),
                      ),
                      Text('${money2(p.monthlyAmount)} شهرياً',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: c.primary)),
                    ],
                  ),
                )),
          ],
        ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.add_card, color: Colors.white),
            onPressed: () => _addPeriodicSheet(),
          ),
        ),
      ],
    );
  }

  Future<void> _addPeriodicSheet() async {
    final ctl = context.read<ExpansionController>();
    if (ctl.beneficiaries.isEmpty) {
      uiToast(context, 'سجّل مستفيداً أولاً', error: true);
      return;
    }
    String benId = ctl.beneficiaries.first.id;
    final amount = TextEditingController();
    DateTime start = DateTime.now();

    await uiSheet(
      context,
      title: 'مساعدة دورية جديدة',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiDropdown<String>(
              label: 'المستفيد *',
              value: benId,
              items: ctl.beneficiaries
                  .map((b) => DropdownMenuItem(value: b.id, child: Text(b.fullName)))
                  .toList(),
              onChanged: (v) => setSheet(() => benId = v ?? benId),
            ),
            UiField(label: 'المبلغ الشهري *', controller: amount, keyboardType: TextInputType.number),
            Text('تاريخ البداية: ${start.toIso8601String().split('T').first}',
                style: TextStyle(fontSize: 13, color: App.of(ctx).sub)),
            UiButton(
              text: 'إنشاء',
              onPressed: () async {
                final amt = double.tryParse(amount.text.trim()) ?? 0;
                if (amt <= 0) {
                  uiToast(ctx, 'أدخل مبلغاً صحيحاً', error: true);
                  return;
                }
                try {
                  await ctl.createPeriodicAid({
                    'beneficiary_id': benId,
                    'monthly_amount': amt,
                    'started_on': start.toIso8601String().split('T').first,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
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

  Future<void> _paySheet(PeriodicAidModel p) async {
    final accounts = await ApiService.instance.accounts();
    if (!mounted) return;
    final liquid = accounts.where((a) => a.isLiquid && a.isActive).toList();
    final expenses = accounts.where((a) => a.type == 'expense' && a.isActive).toList();
    if (liquid.isEmpty || expenses.isEmpty) {
      uiToast(context, 'تحتاج حساب صرف ومصروف — أنشئ شجرة الحسابات', error: true);
      return;
    }
    String fromId = liquid.first.id;
    String expId = expenses.first.id;
    final period = DateTime.now().toIso8601String().substring(0, 7);

    await uiSheet(
      context,
      title: 'صرف معاش — ${p.beneficiaryName}',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('المبلغ: ${money2(p.monthlyAmount)} · الفترة: $period',
                style: TextStyle(fontWeight: FontWeight.w800, color: App.of(ctx).tx)),
            UiDropdown<String>(
              label: 'يُصرف من حساب',
              value: fromId,
              items: liquid.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
              onChanged: (v) => setSheet(() => fromId = v!),
            ),
            UiDropdown<String>(
              label: 'حساب المصروف',
              value: expId,
              items: expenses.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
              onChanged: (v) => setSheet(() => expId = v!),
            ),
            UiButton(
              text: 'صرف بقيد مزدوج',
              onPressed: () async {
                try {
                  await context.read<ExpansionController>().payPeriodicAid(p.id, {
                    'period': period, 'from_account_id': fromId, 'expense_account_id': expId,
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    uiToast(ctx, 'تم الصرف وتسجيل القيد', success: true);
                  }
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
