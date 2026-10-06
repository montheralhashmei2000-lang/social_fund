import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _search = TextEditingController();
  String filter = 'الكل';

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
    final canEdit = Rbac.can(role, 'members');

    final q = _search.text.trim();
    final filtered = data.members.where((m) {
      final matchFilter = filter == 'الكل' || m.status == filter;
      final matchSearch = q.isEmpty ||
          m.name.contains(q) ||
          m.nationalId.contains(q) ||
          m.phone.contains(q) ||
          (m.city ?? '').contains(q);
      return matchFilter && matchSearch;
    }).toList();

    final activeCount = data.members.where((m) => m.isActive).length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو الهوية أو الجوال…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      suffixIcon: q.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              }),
                    ),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => _add(),
                      style: FilledButton.styleFrom(
                          backgroundColor: c.primaryMid,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                for (final f in ['الكل', 'نشط', 'معلق'])
                  ChoiceChip(
                    label: Text(
                        '$f (${f == 'الكل' ? data.members.length : f == 'نشط' ? activeCount : data.members.length - activeCount})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    selected: filter == f,
                    selectedColor: c.primary,
                    labelStyle: TextStyle(color: filter == f ? Colors.white : c.sub),
                    onSelected: (_) => setState(() => filter = f),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${filtered.length} عضو', style: TextStyle(fontSize: 12, color: c.mu)),
            if (filtered.isEmpty)
              const EmptyState(icon: Icons.people, text: 'لا يوجد أعضاء مطابقون')
            else
              ...filtered.map((m) => _memberCard(context, m, canEdit)),
          ],
        ),
      ],
    );
  }

  Widget _memberCard(BuildContext context, Member m, bool canEdit) {
    final c = App.of(context);
    return UiCard(
      accentRight: m.isActive ? c.primary : c.warn,
      onTap: () => _profile(m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF388E3C), Color(0xFF1B5E20)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(m.name.isNotEmpty ? m.name[0] : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                    Text('${m.nationalId} · ${m.city ?? '-'}',
                        style: TextStyle(fontSize: 11, color: c.mu)),
                  ],
                ),
              ),
              UiBadge(m.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat(context, 'شهري', money(m.monthlySubscription), c.primary, c.bg),
              _stat(context, 'مدفوع', money(m.totalPaid), c.primary, c.bg),
              _stat(context, 'متأخر', money(m.balanceDue),
                  m.balanceDue > 0 ? c.err : c.primary,
                  m.balanceDue > 0 ? c.err.withValues(alpha: 0.08) : c.bg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color fg, Color bg) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: fg)),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8A9E8C))),
          ],
        ),
      ),
    );
  }

  Future<void> _add() async {
    await uiSheet(context, title: 'إضافة عضو جديد', child: const _MemberForm());
  }

  Future<void> _profile(Member m) async {
    final c = App.of(context);
    final data = context.read<DataController>();
    final role = context.read<AuthController>().user?.role;
    final canEdit = Rbac.can(role, 'members');
    final subs = data.subscriptions.where((s) => s.memberId == m.id).toList();
    final aids = data.aids.where((a) => a.memberId == m.id).toList();

    await uiSheet(
      context,
      title: 'ملف العضو',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFDD835), Color(0xFFF9A825)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(m.name.isNotEmpty ? m.name[0] : '?',
                          style: const TextStyle(
                              color: Color(0xFF003300), fontSize: 22, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                          Text('${m.city ?? '-'} · ${m.joinDate ?? '-'}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (canEdit)
                  Row(
                    children: [
                      for (final (label, icon, onTap, danger) in [
                        ('تعديل', Icons.edit, 'edit', false),
                        (m.isActive ? 'تعليق' : 'تفعيل', Icons.swap_horiz, 'toggle', false),
                        ('حذف', Icons.delete, 'delete', true),
                        ('بطاقة', Icons.qr_code_2, 'card', false),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(top: 12, left: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onTap == 'edit') _edit(m);
                              if (onTap == 'toggle') _toggle(m);
                              if (onTap == 'delete') _confirmDelete(m);
                              if (onTap == 'card') _showQrCard(context, m);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: danger ? Colors.red.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(label,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _infoRow('رقم الهوية', m.nationalId, c),
                _infoRow('الجوال', m.phone, c),
                _infoRow('الاشتراك الشهري', money(m.monthlySubscription), c),
                _infoRow('إجمالي المدفوع', money(m.totalPaid), c),
                _infoRow('المتأخرات', money(m.balanceDue), c),
              ],
            ),
          ),
          if (subs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('سجل الاشتراكات (${subs.length})',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.tx)),
            ...subs.map((s) => Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('${s.paymentDate} · ${s.method}',
                              style: TextStyle(fontSize: 12, color: c.sub))),
                      Text('+${money(s.amount)}',
                          style: TextStyle(fontWeight: FontWeight.w800, color: c.ok, fontSize: 13)),
                    ],
                  ),
                )),
          ],
          if (aids.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('سجل المساعدات (${aids.length})',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.tx)),
            ...aids.map((a) => Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('${a.aidType}\n${a.requestDate}',
                              style: TextStyle(fontSize: 12, color: c.sub))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(money(a.amount),
                              style: TextStyle(fontWeight: FontWeight.w800, color: c.primary, fontSize: 13)),
                          UiBadge(a.status),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
  );
  }

  void _showQrCard(BuildContext context, Member m) {
    final c = App.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('بطاقة العضوية', style: AppTheme.sectionTitle(c, size: 18)),
            const SizedBox(height: 4),
            Text(m.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.tx)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: QrImageView(
                data: 'SF-MEMBER:${m.id}',
                size: 190,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text('الهوية: ${m.nationalId} · ${m.phone}', style: TextStyle(fontSize: 12, color: c.mu)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String k, String v, AppColors c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: c.sub, fontSize: 13)),
            Text(v, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.tx)),
          ],
        ),
      );

  Future<void> _edit(Member m) async {
    await uiSheet(context, title: 'تعديل عضو', child: _MemberForm(member: m));
  }

  Future<void> _toggle(Member m) async {
    try {
      await context.read<DataController>().toggleMemberStatus(m);
      if (mounted) uiToast(context, 'تم تحديث الحالة', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  Future<void> _confirmDelete(Member m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('حذف العضو "${m.name}" نهائياً؟ لا يمكن التراجع.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
              child: const Text('حذف نهائياً')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<DataController>().deleteMember(m.id);
      if (mounted) uiToast(context, 'تم حذف العضو', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }
}

/// نموذج إضافة/تعديل عضو - الحقول المطلوبة كما في النسخة السابقة.
class _MemberForm extends StatefulWidget {
  final Member? member;
  const _MemberForm({this.member});

  @override
  State<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<_MemberForm> {
  late final name = TextEditingController(text: widget.member?.name ?? '');
  late final nid = TextEditingController(text: widget.member?.nationalId ?? '');
  late final phone = TextEditingController(text: widget.member?.phone ?? '');
  late final city = TextEditingController(text: widget.member?.city ?? '');
  late final join = TextEditingController(text: widget.member?.joinDate ?? '');
  late final sub = TextEditingController(text: (widget.member?.monthlySubscription ?? 500).toString());
  bool busy = false;
  String? err;

  @override
  void dispose() {
    name.dispose();
    nid.dispose();
    phone.dispose();
    city.dispose();
    join.dispose();
    sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiField(label: 'الاسم الرباعي *', controller: name, hint: 'أحمد محمد الصالح', icon: Icons.person_outline),
        UiField(label: 'رقم الهوية *', controller: nid, hint: '1234567890', icon: Icons.badge_outlined, keyboardType: TextInputType.number),
        UiField(label: 'رقم الجوال *', controller: phone, hint: '07XXXXXXXX', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        UiField(label: 'المدينة', controller: city, hint: 'صنعاء'),
        UiField(label: 'تاريخ الانضمام', controller: join, hint: '2024-01-01'),
        UiField(label: 'الاشتراك الشهري (﷼)', controller: sub, keyboardType: TextInputType.number, icon: Icons.payments_outlined),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(err!, style: TextStyle(color: App.of(context).err, fontSize: 12)),
          ),
        UiButton(
          text: busy ? 'جارٍ الحفظ…' : (widget.member == null ? 'إضافة العضو' : 'حفظ التعديلات'),
          onPressed: busy
              ? null
              : () async {
                  if (name.text.trim().isEmpty || nid.text.trim().isEmpty || phone.text.trim().isEmpty) {
                    setState(() => err = 'يرجى ملء الحقول المطلوبة');
                    return;
                  }
                  setState(() {
                    busy = true;
                    err = null;
                  });
                  try {
                    final data = context.read<DataController>();
                    if (widget.member == null) {
                      await data.addMember(
                        name: name.text.trim(),
                        nationalId: nid.text.trim(),
                        phone: phone.text.trim(),
                        city: city.text.trim().isEmpty ? null : city.text.trim(),
                        joinDate: join.text.trim().isEmpty ? null : join.text.trim(),
                        monthlySubscription: int.tryParse(sub.text.trim()) ?? 0,
                      );
                    } else {
                      await data.updateMember(widget.member!.id, {
                        'name': name.text.trim(),
                        'national_id': nid.text.trim(),
                        'phone': phone.text.trim(),
                        'city': city.text.trim().isEmpty ? null : city.text.trim(),
                        'join_date': join.text.trim().isEmpty ? null : join.text.trim(),
                        'monthly_subscription': int.tryParse(sub.text.trim()) ?? 0,
                      });
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      uiToast(context, widget.member == null ? 'تمت إضافة العضو' : 'تم تحديث البيانات',
                          success: true);
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
