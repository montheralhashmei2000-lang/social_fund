import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/rbac.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import '../screens/card_scan_screen.dart';

/// الملخص التنفيذي: صورة كاملة أعلى لوحة المعلومات — صافي الخزينة،
/// الطلبات المعلقة، الحملات النشطة بتقدمها، وزر التحقق الميداني من البطاقات.
class ExecutiveSummaryCard extends StatefulWidget {
  const ExecutiveSummaryCard({super.key});

  @override
  State<ExecutiveSummaryCard> createState() => _ExecutiveSummaryCardState();
}

class _ExecutiveSummaryCardState extends State<ExecutiveSummaryCard> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final exp = context.read<ExpansionController>();
      await exp.loadCampaigns();
      if (mounted) setState(() => loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final exp = context.watch<ExpansionController>();
    final role = context.read<AuthController>().user?.role;
    final active = exp.campaigns.where((x) => x.status != 'closed').take(3).toList();
    final net = data.treasuryBalance;

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 26, height: 3, color: c.gold),
              const SizedBox(width: 8),
              Expanded(child: Text('الملخص التنفيذي', style: AppTheme.sectionTitle(c, size: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _stat('صافي الخزينة', money(net), net >= 0 ? c.ok : c.err)),
              Expanded(child: _stat('طلبات معلقة', '${data.pendingAidsCount}', c.warn)),
              Expanded(child: _stat('حملات نشطة', '${active.length}', c.primary)),
            ],
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final camp in active)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(camp.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.tx)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: camp.percent.clamp(0.0, 100.0) / 100,
                              minHeight: 6, backgroundColor: c.surf, color: c.gold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${camp.percent}%',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: c.goldDark)),
                  ],
                ),
              ),
          ],
          if (Rbac.can(role, 'aids')) ...[
            const SizedBox(height: 6),
            UiButton(
              text: 'تحقق ميداني من بطاقة عضوية (مسح QR)',
              variant: 'gold',
              small: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardScanScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    final c = App.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        Text(label, style: TextStyle(fontSize: 10.5, color: c.mu)),
      ],
    );
  }
}
