import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import 'home_shell.dart' show Tabs;
import 'subscriptions_screen.dart' show payMethods;

/// سندات القبض والصرف — مربوطة بالقيد المزدوج: كل سند يولّد قيد يومية متوازناً
/// (يظهر في دفتر القيود وشجرة الحسابات والقوائم المالية) ومعاملة خزينة مرآتية.
class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  String kind = 'قبض';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final role = context.read<AuthController>().user?.role;
    final canCreate = Rbac.can(role, 'vouchers');
    final q = _search.text.trim();

    final kindAll = data.vouchers.where((v) => v.kind == kind).toList();
    final shown = kindAll.where((v) {
      if (q.isEmpty) return true;
      return v.voucherNo.contains(q) || v.party.contains(q) || v.description.contains(q);
    }).toList();
    final activeCount = kindAll.where((v) => !v.isVoid).length;
    final total = kindAll.where((v) => !v.isVoid).fold<int>(0, (s, v) => s + v.amount);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'قبض', label: Text('سندات قبض'), icon: Icon(Icons.download)),
                ButtonSegment(value: 'صرف', label: Text('سندات صرف'), icon: Icon(Icons.upload)),
              ],
              selected: {kind},
              onSelectionChanged: (s) => setState(() => kind = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected) ? c.primary : c.card),
                foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected) ? Colors.white : c.sub),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _stat(context, 'سندات معتمدة', '$activeCount', c.primary)),
                const SizedBox(width: 10),
                Expanded(
                    child: _stat(context, 'إجمالي السندات', money(total), kind == 'قبض' ? c.ok : c.err)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'بحث برقم السند أو الطرف أو الوصف…',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Text('كل سند يولّد قيداً محاسبياً متوازناً تلقائياً في الخادم',
                style: TextStyle(fontSize: 11, color: c.mu)),
            const SizedBox(height: 6),
            if (shown.isEmpty)
              const EmptyState(icon: Icons.approval, text: 'لا توجد سندات')
            else
              ...shown.map((v) => _voucherCard(context, v)),
          ],
        ),
        if (canCreate)
          Positioned(
            bottom: 18,
            left: 18,
            child: FloatingActionButton.extended(
              heroTag: 'addVoucher',
              backgroundColor: kind == 'قبض' ? c.primaryMid : c.goldDark,
              icon: const Icon(Icons.post_add, color: Colors.white),
              label: Text('سند ${kind == 'قبض' ? 'قبض' : 'صرف'} جديد',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              onPressed: _add,
            ),
          ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    final c = App.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: c.gold, width: 2)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: c.mu)),
        ],
      ),
    );
  }

  Widget _voucherCard(BuildContext context, Voucher v) {
    final c = App.of(context);
    final col = v.isVoid ? c.mu : (v.isReceipt ? c.ok : c.err);
    return UiCard(
      accentRight: col,
      onTap: () => _preview(v),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(v.isVoid ? Icons.block : v.isReceipt ? Icons.download : Icons.upload, color: col),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.voucherNo, style: AppTheme.sectionTitle(c, size: 13.5)),
                Text('${v.party} · ${v.description}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: c.tx)),
                Text('${v.voucherDate} · ${v.method} · القيد: ${v.journalEntryNo ?? '-'}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: c.mu)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${v.isReceipt ? '+' : '-'}${money(v.amount)}',
                  style: TextStyle(fontWeight: FontWeight.w900, color: col, fontSize: 14.5)),
              const SizedBox(height: 3),
              UiBadge(v.isVoid ? 'ملغي' : 'معتمد'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    await uiSheet(
      context,
      title: 'إصدار سند $kind',
      accent: kind == 'قبض' ? null : App.of(context).goldDark,
      child: _AddVoucherForm(initialKind: kind),
    );
  }

  Future<void> _preview(Voucher v) async {
    final data = context.read<DataController>();
    final fund = data.fundSettings;
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fund?.name ?? 'الصندوق الاجتماعي التنموي',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0D1B0F))),
                          IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey)),
                        ],
                      ),
                      Text('الجمهورية اليمنية', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          color: v.isReceipt ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
                          child: Text('سند ${v.kind}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ),
                      Center(
                          child: Text(v.voucherNo,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0D1B0F)))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: v.isReceipt ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(v.isReceipt ? 'المبلغ المستلم' : 'المبلغ المصروف',
                                style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            Text(money(v.amount),
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w900,
                                    color: v.isReceipt ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _row(v.isReceipt ? 'استلمنا من السيد/ة' : 'صرفنا إلى السيد/ة', v.party),
                      _row('وذلك مقابل', v.description),
                      _row('طريقة الدفع', v.method),
                      _row('التاريخ', v.voucherDate),
                      _row('القيد المحاسبي', v.journalEntryNo ?? '-'),
                      _row('الحالة', v.status),
                      _row(v.isReceipt ? 'استلم بواسطة' : 'صرف بواسطة', v.issuedByName),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Container(width: 90, height: 1, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text('توقيع ${v.isReceipt ? 'المستلم' : 'المستفيد'}',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                            ],
                          ),
                          Column(
                            children: [
                              Container(width: 90, height: 1, color: Colors.grey),
                              const SizedBox(height: 4),
                              const Text('الختم الرسمي', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      if ((fund?.phone ?? '').isNotEmpty || (fund?.address ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            [
                              if ((fund?.address ?? '').isNotEmpty) fund!.address!,
                              if ((fund?.phone ?? '').isNotEmpty) '☎ ${fund!.phone}',
                            ].join(' · '),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: UiButton(
                        text: 'مشاركة PDF',
                        variant: 'gold',
                        small: true,
                        onPressed: () => _sharePdf(v),
                      ),
                    ),
                    if (!v.isVoid) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: UiButton(
                          text: 'إلغاء السند',
                          variant: 'danger',
                          small: true,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmVoid(v);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$k: ',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4A5E4D))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 12.5, color: Color(0xFF0D1B0F)))),
          ],
        ),
      );

  Future<void> _sharePdf(Voucher v) async {
    try {
      final bytes = await ApiService.instance.voucherPdfBytes(v.id);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/${v.voucherNo}.pdf');
      await f.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(f.path)], text: 'سند ${v.kind} ${v.voucherNo}');
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر تجهيز ملف السند', error: true);
    }
  }

  Future<void> _confirmVoid(Voucher v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء السند؟'),
        content: Text(
            'سيُنشأ قيد محاسبي عكسي للسند ${v.voucherNo} ويُعطَّل سجله في الخزينة. القيد الأصلي يبقى موثقاً ولا يمكن التراجع.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('رجوع')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
              child: const Text('إلغاء السند')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<DataController>().voidVoucher(v.id);
      if (mounted) uiToast(context, 'تم إلغاء السند بقيد عكسي', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }
}

/// نموذج إصدار سند: طرف (عضو/مانح/مستفيد/جهة حرة) + حساب خزينة + حساب مقابل.
class _AddVoucherForm extends StatefulWidget {
  final String initialKind;
  const _AddVoucherForm({required this.initialKind});

  @override
  State<_AddVoucherForm> createState() => _AddVoucherFormState();
}

class _AddVoucherFormState extends State<_AddVoucherForm> {
  late String kind = widget.initialKind;
  String partySource = 'member'; // member | donor | beneficiary | other
  String? memberId;
  String? donorId;
  String? beneficiaryId;
  final partyOther = TextEditingController();
  final amount = TextEditingController();
  final description = TextEditingController();
  String method = 'نقداً';
  DateTime date = DateTime.now();
  List<Account> accounts = [];
  String? treasuryIdState;
  String? counterId;
  bool loadingAccounts = true;
  bool busy = false;
  String? err;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>()
        ..loadDonors()
        ..loadBeneficiaries();
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    try {
      final accs = await ApiService.instance.accounts();
      if (mounted) {
        setState(() {
          accounts = accs;
          loadingAccounts = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          err = e.message;
          loadingAccounts = false;
        });
      }
    }
  }

  List<Member> _members(BuildContext context) => context.read<DataController>().members;

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final exp = context.watch<ExpansionController>();

    if (loadingAccounts) return const Padding(padding: EdgeInsets.all(24), child: LoadingView());

    final liquid = accounts.where((a) => a.isLiquid && a.isActive).toList();
    final counterList = accounts.where((a) => a.isActive).toList();

    if (liquid.isEmpty || counterList.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const EmptyState(icon: Icons.account_balance, text: 'شجرة الحسابات غير مهيأة — السندات تُسجل قيداً مزدوجاً'),
          UiButton(
            text: 'الذهاب إلى الحسابات وإنشاء الشجرة',
            onPressed: () => PushService.openTab.value = Tabs.accounts,
          ),
        ],
      );
    }

    final treasurySel = treasuryIdState ?? liquid.first.id;
    final counterChoices = counterList.where((a) => a.id != treasurySel).toList();
    final counterSel = (counterId != null && counterId != treasurySel && counterChoices.any((a) => a.id == counterId))
        ? counterId
        : (counterChoices.isNotEmpty ? counterChoices.first.id : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiDropdown<String>(
          label: 'نوع السند',
          value: kind,
          items: const [
            DropdownMenuItem(value: 'قبض', child: Text('قبض (دخول نقد)')),
            DropdownMenuItem(value: 'صرف', child: Text('صرف (خروج نقد)')),
          ],
          onChanged: (v) => setState(() => kind = v ?? 'قبض'),
        ),
        Wrap(
          spacing: 6,
          children: [
            for (final (key, label) in [('member', 'عضو'), ('donor', 'مانح'), ('beneficiary', 'مستفيد'), ('other', 'جهة أخرى')])
              ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                selected: partySource == key,
                selectedColor: c.primary,
                labelStyle: TextStyle(color: partySource == key ? Colors.white : c.sub),
                onSelected: (_) => setState(() => partySource = key),
              ),
          ],
        ),
        if (partySource == 'member')
          UiDropdown<String>(
            label: 'العضو *',
            value: memberId ?? (_members(context).isNotEmpty ? _members(context).first.id : null),
            items: _members(context).map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
            onChanged: (v) => setState(() => memberId = v),
          )
        else if (partySource == 'donor')
          UiDropdown<String>(
            label: 'المانح *',
            value: donorId ?? (exp.donors.isNotEmpty ? exp.donors.first.id : null),
            items: exp.donors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
            onChanged: (v) => setState(() => donorId = v),
          )
        else if (partySource == 'beneficiary')
          UiDropdown<String>(
            label: 'المستفيد *',
            value: beneficiaryId ?? (exp.beneficiaries.isNotEmpty ? exp.beneficiaries.first.id : null),
            items: exp.beneficiaries.map((b) => DropdownMenuItem(value: b.id, child: Text(b.fullName))).toList(),
            onChanged: (v) => setState(() => beneficiaryId = v),
          )
        else
          UiField(label: 'اسم الجهة *', controller: partyOther, hint: 'اسم منشأة / شخص غير مسجل'),
        UiDropdown<String>(
          label: kind == 'قبض' ? 'يُستلم في حساب (خزينة/بنك) *' : 'يُصرف من حساب (خزينة/بنك) *',
          value: treasurySel,
          items: liquid.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
          onChanged: (v) => setState(() => treasuryIdState = v),
        ),
        if (counterChoices.isNotEmpty)
          UiDropdown<String>(
            label: kind == 'قبض' ? 'الحساب المقابل (مصدر الإيراد) *' : 'الحساب المقابل (حساب المصروف) *',
            value: counterSel,
            items: counterChoices.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
            onChanged: (v) => setState(() => counterId = v),
          ),
        UiField(label: 'المبلغ (﷼) *', controller: amount, keyboardType: TextInputType.number, icon: Icons.payments_outlined),
        UiField(label: 'الوصف *', controller: description, hint: 'سبب إصدار السند'),
        UiDropdown<String>(
          label: 'طريقة الدفع',
          value: method,
          items: payMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => method = v ?? 'نقداً'),
        ),
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(10)),
          child: Text(
            'سيُنشأ قيد مزدوج متوازن تلقائياً: ${kind == 'قبض' ? 'مدين حساب الخزينة / دائن الحساب المقابل' : 'مدين الحساب المقابل / دائن حساب الخزينة'}',
            style: TextStyle(fontSize: 11.5, color: c.sub),
          ),
        ),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 6),
            child: Text(err!, style: TextStyle(color: c.err, fontSize: 12)),
          ),
        UiButton(
          text: busy ? 'جارٍ الإصدار…' : 'إصدار السند',
          variant: kind == 'قبض' ? 'primary' : 'gold',
          onPressed: busy ? null : () => _submit(context, treasurySel, counterSel),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, String treasurySel, String? counterSel) async {
    final amt = int.tryParse(amount.text.trim()) ?? 0;
    final desc = description.text.trim();

    String? partyId;
    String? partyName;
    if (partySource == 'member') {
      if (_members(context).isEmpty) {
        setState(() => err = 'أضف عضواً أولاً أو اختر جهة أخرى');
        return;
      }
      partyId = memberId ?? _members(context).first.id;
    }
    if (partySource == 'donor') partyId = donorId;
    if (partySource == 'beneficiary') partyId = beneficiaryId;
    if (partySource == 'other') {
      partyName = partyOther.text.trim();
      if (partyName.isEmpty) {
        setState(() => err = 'أدخل اسم الجهة');
        return;
      }
    }
    if ((partySource == 'donor' && donorId == null) || (partySource == 'beneficiary' && beneficiaryId == null)) {
      setState(() => err = 'القائمة فارغة — سجّل الطرف أولاً أو اختر جهة أخرى');
      return;
    }
    if (amt <= 0 || desc.isEmpty || counterSel == null) {
      setState(() => err = 'أكمل المبلغ والوصف والحسابين');
      return;
    }
    setState(() {
      busy = true;
      err = null;
    });
    try {
      await context.read<DataController>().createVoucher({
        'kind': kind,
        'amount': amt,
        'voucher_date': date.toIso8601String().split('T').first,
        'method': method,
        'description': desc,
        if (partySource == 'member') 'member_id': partyId,
        if (partySource == 'donor') 'donor_id': partyId,
        if (partySource == 'beneficiary') 'beneficiary_id': partyId,
        if (partyName != null) 'party_name': partyName,
        'treasury_account_id': treasurySel,
        'counter_account_id': counterSel,
      });
      if (context.mounted) {
        Navigator.pop(context);
        uiToast(context, 'تم إصدار السند وتسجيل قيده المحاسبي المتوازن', success: true);
      }
    } on ApiException catch (e) {
      setState(() => err = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
