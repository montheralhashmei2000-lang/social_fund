import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/num_parse.dart';
import '../core/theme.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>().loadCampaigns();
    });
  }

  String filter = 'الكل';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.campaigns.isEmpty) return const LoadingView();

    final all = ctl.campaigns;
    final active = all.where((x) => x.status != 'closed').toList();
    final q = query.trim();
    final shown = [
      for (final x in all)
        if ((filter == 'الكل' || (filter == 'نشطة') == (x.status != 'closed')) &&
            (q.isEmpty || '${x.name} ${x.description ?? ''}'.contains(q)))
          x,
    ];
    double sum(Iterable list, num Function(dynamic) f) => list.fold(0.0, (s, x) => s + f(x));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCampaignSheet,
        icon: const Icon(Icons.add),
        label: const Text('حملة جديدة'),
      ),
      body: all.isEmpty
          ? EmptyState(
              icon: Icons.campaign,
              text: 'لا حملات بعد',
              subtitle: 'أنشئ حملة جمع تبرعات بهدف مالي لتتابع تقدمها ومصروفاتها',
              actionText: 'حملة جديدة',
              onAction: _addCampaignSheet,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.campaign,
                        label: 'حملات نشطة',
                        value: '${active.length}',
                        sub: 'من ${all.length}',
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        icon: Icons.savings,
                        label: 'المجموع في النشطة',
                        value: money2(sum(active, (x) => x.raised as num)),
                        sub: 'من هدف ${money2(sum(active, (x) => x.goalAmount as num))}',
                        color: c.goldDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SearchField(hint: 'ابحث باسم الحملة…', onChanged: (v) => setState(() => query = v)),
                const SizedBox(height: 10),
                FilterChipsBar(
                  options: const ['الكل', 'نشطة', 'مغلقة'],
                  selected: filter,
                  counts: {'الكل': all.length, 'نشطة': active.length, 'مغلقة': all.length - active.length},
                  onSelected: (v) => setState(() => filter = v),
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  const EmptyState(icon: Icons.search_off, text: 'لا نتائج مطابقة')
                else
                  ...shown.map((camp) => _campaignCard(context, camp)),
              ],
            ),
    );
  }

  Widget _campaignCard(BuildContext context, camp) {
    final c = App.of(context);
    final pct = (((camp.percent as num?) ?? 0).toDouble()).clamp(0.0, 100.0);
    final closed = camp.status == 'closed';
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(camp.name,
                    style: AppTheme.sectionTitle(c, size: 15)),
              ),
              if (closed) const UiBadge('مغلقة') else const UiBadge('نشطة'),
              if (!closed)
                IconButton(
                  icon: Icon(Icons.lock_outline, size: 19, color: c.mu),
                  tooltip: 'إغلاق الحملة',
                  onPressed: () async {
                    try {
                      await context.read<ExpansionController>().closeCampaign(camp.id);
                      if (context.mounted) uiToast(context, 'تم إغلاق الحملة', success: true);
                    } on ApiException catch (e) {
                      if (context.mounted) uiToast(context, e.message, error: true);
                    }
                  },
                ),
            ],
          ),
          if (camp.description != null && camp.description!.isNotEmpty)
            Text(camp.description!,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: c.sub)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 10,
              backgroundColor: c.surf,
              color: pct >= 100 ? c.ok : c.gold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المجموع: ${money2(camp.raised)}',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: c.primary)),
              Text('الهدف: ${money2(camp.goalAmount)}',
                  style: TextStyle(fontSize: 12, color: c.mu)),
              Text('${camp.percent}%',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: c.goldDark)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المصروف: ${money2(camp.spent)}',
                  style: TextStyle(fontSize: 12, color: c.err)),
              Text('الصافي: ${money2(camp.net)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.info)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addCampaignSheet() async {
    final ctl = context.read<ExpansionController>();
    final name = TextEditingController();
    final desc = TextEditingController();
    final goal = TextEditingController();
    DateTime start = DateTime.now();
    DateTime? end;

    await uiSheet(
      context,
      title: 'حملة تبرعات جديدة',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'اسم الحملة *', controller: name, hint: 'حملة مساعدة المرضى'),
            UiField(label: 'الوصف', controller: desc, maxLines: 2),
            UiField(label: 'المبلغ المستهدف *', controller: goal, keyboardType: TextInputType.number),
            Row(
              children: [
                Expanded(child: Text('البداية: ${start.toIso8601String().split('T').first}',
                    style: TextStyle(fontSize: 13, color: App.of(ctx).sub))),
                TextButton(
                  onPressed: () async {
                    final p = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (p != null) setSheet(() => start = p);
                  },
                  child: const Text('تغيير'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('النهاية: ${end?.toIso8601String().split('T').first ?? 'بدون'}',
                    style: TextStyle(fontSize: 13, color: App.of(ctx).sub))),
                TextButton(
                  onPressed: () async {
                    final p = await showDatePicker(context: ctx, initialDate: end ?? start, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (p != null) setSheet(() => end = p);
                  },
                  child: const Text('تغيير'),
                ),
              ],
            ),
            UiButton(
              text: 'إنشاء الحملة',
              onPressed: () async {
                final g = parseDouble(goal.text.trim()) ?? 0;
                if (name.text.trim().isEmpty || g <= 0) {
                  uiToast(ctx, 'أكمل الاسم والهدف', error: true);
                  return;
                }
                try {
                  await ctl.createCampaign({
                    'name': name.text.trim(),
                    'description': desc.text.trim().isEmpty ? null : desc.text.trim(),
                    'goal_amount': g,
                    'start_date': start.toIso8601String().split('T').first,
                    'end_date': end?.toIso8601String().split('T').first,
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
