import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';

class InKindScreen extends StatefulWidget {
  const InKindScreen({super.key});

  @override
  State<InKindScreen> createState() => _InKindScreenState();
}

class _InKindScreenState extends State<InKindScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>().loadInKind();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.inKindItems.isEmpty) return const LoadingView();

    return Stack(
      children: [
        if (ctl.inKindItems.isEmpty)
          const Center(child: EmptyState(icon: Icons.inventory_2, text: 'لا بنود مخزون بعد'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...ctl.inKindItems.map((i) => UiCard(
                    accentRight: i.lowStock ? c.warn : c.primary,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (i.lowStock ? c.warn : c.primary).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.inventory_2,
                              color: i.lowStock ? c.warn : c.primary, size: 21),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(i.name,
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
                              Text('الحد الأدنى: ${i.reorderLevel} ${i.unit}',
                                  style: TextStyle(fontSize: 11, color: c.mu)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${i.quantity} ${i.unit}',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14,
                                    color: i.lowStock ? c.warn : c.primary)),
                            if (i.lowStock)
                              Text('مخزون منخفض!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c.err)),
                          ],
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: Icon(Icons.swap_vert, color: c.info, size: 21),
                          tooltip: 'حركة مخزون',
                          onPressed: () => _movementSheet(i.id, i.name),
                        ),
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
            child: const Icon(Icons.add_box, color: Colors.white),
            onPressed: () => _addItemSheet(),
          ),
        ),
      ],
    );
  }

  Future<void> _addItemSheet() async {
    final ctl = context.read<ExpansionController>();
    final name = TextEditingController();
    final unit = TextEditingController(text: 'قطعة');
    final reorder = TextEditingController(text: '0');

    await uiSheet(
      context,
      title: 'بند مخزون عيني',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiField(label: 'اسم البند *', controller: name, hint: 'سلة غذائية / بطانية…'),
          UiField(label: 'وحدة القياس', controller: unit),
          UiField(label: 'حد إعادة الطلب', controller: reorder, keyboardType: TextInputType.number),
          UiButton(
            text: 'إضافة البند',
            onPressed: () async {
              if (name.text.trim().isEmpty) {
                uiToast(context, 'أدخل اسم البند', error: true);
                return;
              }
              try {
                await ctl.createInKindItem({
                  'name': name.text.trim(), 'unit': unit.text.trim(),
                  'reorder_level': double.tryParse(reorder.text.trim()) ?? 0,
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

  Future<void> _movementSheet(String itemId, String itemName) async {
    final ctl = context.read<ExpansionController>();
    String direction = 'in';
    final qty = TextEditingController();
    final note = TextEditingController();

    await uiSheet(
      context,
      title: 'حركة مخزون: $itemName',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'in', label: Text('إدخال'), icon: Icon(Icons.south_west)),
                ButtonSegment(value: 'out', label: Text('إخراج'), icon: Icon(Icons.north_east)),
              ],
              selected: {direction},
              onSelectionChanged: (s) => setSheet(() => direction = s.first),
            ),
            UiField(label: 'الكمية *', controller: qty, keyboardType: TextInputType.number),
            UiField(label: 'ملاحظة', controller: note),
            UiButton(
              text: 'تسجيل الحركة',
              onPressed: () async {
                final q = double.tryParse(qty.text.trim()) ?? 0;
                if (q <= 0) {
                  uiToast(ctx, 'أدخل كمية صحيحة', error: true);
                  return;
                }
                try {
                  await ctl.createMovement({
                    'item_id': itemId, 'direction': direction, 'quantity': q,
                    'movement_date': DateTime.now().toIso8601String().split('T').first,
                    'note': note.text.trim().isEmpty ? null : note.text.trim(),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    uiToast(ctx, 'تم تسجيل الحركة', success: true);
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
