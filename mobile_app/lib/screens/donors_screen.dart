import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';

class DonorsScreen extends StatefulWidget {
  const DonorsScreen({super.key});

  @override
  State<DonorsScreen> createState() => _DonorsScreenState();
}

class _DonorsScreenState extends State<DonorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>().loadDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();
    final duePledges = ctl.pledges.where((p) => p.nextDue != null && (p.daysOverdue ?? 0) >= 0).toList();

    if (ctl.loading && ctl.donors.isEmpty) return const LoadingView();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (duePledges.isNotEmpty) ...[
              UiCard(
                accentRight: c.warn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('وعود مستحقة للمتابعة (${duePledges.length})',
                        style: AppTheme.sectionTitle(c, size: 13)),
                    ...duePledges.take(3).map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text('• ${p.donorName}: ${money2(p.amount)} ${p.frequencyLabel} — متأخر ${p.daysOverdue ?? 0} يوم',
                              style: TextStyle(fontSize: 12, color: c.warn)),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (ctl.donors.isEmpty)
              const Center(child: EmptyState(icon: Icons.handshake, text: 'لا مانحين بعد'))
            else
              ...ctl.donors.map((d) => _donorCard(context, d)),
          ],
        ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.person_add_alt, color: Colors.white),
            onPressed: () => _addDonorSheet(),
          ),
        ),
      ],
    );
  }

  Widget _donorCard(BuildContext context, Donor d) {
    final c = App.of(context);
    final tierColor = switch (d.tier) {
      'platinum' => c.info,
      'gold' => c.goldDark,
      'silver' => c.mu,
      _ => c.primary,
    };
    return UiCard(
      onTap: () => _donorDetail(d),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(d.name.isNotEmpty ? d.name[0] : '?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: tierColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                Text(d.donorTypeLabel, style: TextStyle(fontSize: 11, color: c.mu)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money2(d.totalDonated),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: c.primary)),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(d.tierLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tierColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _donorDetail(Donor d) async {
    try {
      final detail = Map<String, dynamic>.from(
          await ApiService.instance.request('GET', '/donors/${d.id}'));
      if (!mounted) return;
      final donations = (detail['donations'] as List?) ?? [];
      final pledges = (detail['pledges'] as List?) ?? [];

      await uiSheet(
        context,
        title: 'ملف المانح',
        accent: App.of(context).goldDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.name, style: AppTheme.sectionTitle(App.of(context), size: 15)),
                Text('إجمالي: ${money2(d.totalDonated)}',
                    style: TextStyle(fontWeight: FontWeight.w900, color: App.of(context).primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text('التبرعات (${donations.length})', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: App.of(context).sub)),
            ...donations.map((raw) {
              final x = Map<String, dynamic>.from(raw as Map);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${x['description']}', style: const TextStyle(fontSize: 12.5)),
                subtitle: Text('${x['entry_no']} · ${x['entry_date']}', style: const TextStyle(fontSize: 11)),
                trailing: Text(money2((x['amount'] as num).toDouble()),
                    style: TextStyle(fontWeight: FontWeight.w800, color: App.of(context).ok)),
              );
            }),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: UiButton(
                    text: 'شهادة شكر (PDF)',
                    variant: 'gold',
                    small: true,
                    onPressed: () => _certificate(d),
                  ),
                ),
              ],
            ),
            if (pledges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('الوعود (${pledges.length})', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: App.of(context).sub)),
              ...pledges.map((raw) {
                final x = Map<String, dynamic>.from(raw as Map);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${money2((x['amount'] as num).toDouble())} ${x['frequency_label'] ?? ''}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  subtitle: Text('منذ ${x['start_date']} · ${x['status']}', style: const TextStyle(fontSize: 11)),
                );
              }),
            ],
          ],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  Future<void> _certificate(Donor d) async {
    try {
      final res = await ApiService.instance.dio.request<List<int>>(
        '/donors/${d.id}/certificate',
        options: Options(responseType: ResponseType.bytes),
      );
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/certificate_${d.name}.pdf');
      await f.writeAsBytes(res.data ?? <int>[]);
      await Share.shareXFiles([XFile(f.path)], text: 'شهادة شكر - ${d.name}');
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر تجهيز الشهادة', error: true);
    }
  }

  Future<void> _addDonorSheet() async {
    final ctl = context.read<ExpansionController>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final notes = TextEditingController();
    String donorType = 'merchant';
    String tier = 'silver';

    await uiSheet(
      context,
      title: 'مانح جديد',
      accent: App.of(context).goldDark,
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'اسم المانح *', controller: name, hint: 'متجر / مؤسسة / اسم محسن'),
            UiDropdown<String>(
              label: 'التصنيف',
              value: donorType,
              items: const [
                DropdownMenuItem(value: 'merchant', child: Text('تاجر')),
                DropdownMenuItem(value: 'organization', child: Text('مؤسسة')),
                DropdownMenuItem(value: 'individual', child: Text('فرد محسن')),
                DropdownMenuItem(value: 'philanthropist', child: Text('واعظ خير')),
              ],
              onChanged: (v) => setSheet(() => donorType = v ?? donorType),
            ),
            UiDropdown<String>(
              label: 'المستوى',
              value: tier,
              items: const [
                DropdownMenuItem(value: 'bronze', child: Text('برونزي')),
                DropdownMenuItem(value: 'silver', child: Text('فضي')),
                DropdownMenuItem(value: 'gold', child: Text('ذهبي')),
                DropdownMenuItem(value: 'platinum', child: Text('بلاتيني')),
              ],
              onChanged: (v) => setSheet(() => tier = v ?? tier),
            ),
            UiField(label: 'الهاتف', controller: phone, keyboardType: TextInputType.phone),
            UiField(label: 'البريد', controller: email, keyboardType: TextInputType.emailAddress),
            UiField(label: 'ملاحظات', controller: notes, maxLines: 2),
            UiButton(
              text: 'إضافة المانح',
              variant: 'gold',
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  uiToast(ctx, 'أدخل اسم المانح', error: true);
                  return;
                }
                try {
                  await ctl.createDonor({
                    'name': name.text.trim(), 'donor_type': donorType, 'tier': tier,
                    'phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
                    'email': email.text.trim().isEmpty ? null : email.text.trim(),
                    'notes': notes.text.trim().isEmpty ? null : notes.text.trim(),
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
}

