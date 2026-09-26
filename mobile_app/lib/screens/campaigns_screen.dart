import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';

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

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.campaigns.isEmpty) return const LoadingView();

    return Stack(
      children: [
        if (ctl.campaigns.isEmpty)
          const Center(child: EmptyState(icon: Icons.campaign, text: 'لا حملات بعد — أنشئ حملة جمع تبرعات'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: ctl.campaigns.map((camp) => _campaignCard(context, camp)).toList(),
          ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _addCampaignSheet(),
          ),
        ),
      ],
    );
  }

  Widget _campaignCard(BuildContext context, camp) {
    final c = App.of(context);
    final pct = (camp.percent as double).clamp(0.0, 100.0);
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
                final g = double.tryParse(goal.text.trim()) ?? 0;
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
