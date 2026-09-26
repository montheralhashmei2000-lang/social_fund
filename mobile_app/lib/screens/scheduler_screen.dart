import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final events = [...data.events]..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return Stack(
      children: [
        if (events.isEmpty)
          const Center(child: EmptyState(icon: Icons.event, text: 'لا توجد مواعيد مسجلة'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: events.map((e) {
              final color = _color(e.color, c);
              return UiCard(
                accentRight: color,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_dayOfMonth(e.eventDate),
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
                          const SizedBox(height: 2),
                          Text(
                            '${e.eventDate}'
                            '${e.eventTime != null && e.eventTime!.isNotEmpty ? ' · ${e.eventTime}' : ''}'
                            '${e.place != null && e.place!.isNotEmpty ? ' · ${e.place}' : ''}',
                            style: TextStyle(fontSize: 11.5, color: c.mu),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: c.err, size: 20),
                      onPressed: () => _confirmDelete(e),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            onPressed: _add,
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _color(String hex, AppColors c) {
    final v = hex.replaceFirst('#', '');
    if (v.length == 6) {
      final parsed = int.tryParse('FF$v', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return c.primary;
  }

  String _dayOfMonth(String date) {
    final parts = date.split('-');
    return parts.length >= 3 ? parts[2] : date;
  }

  Future<void> _confirmDelete(EventModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الموعد'),
        content: Text('حذف "${e.title}" نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<DataController>().deleteEvent(e.id);
      if (mounted) uiToast(context, 'تم حذف الموعد', success: true);
    } on ApiException catch (err) {
      if (mounted) uiToast(context, err.message, error: true);
    }
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final time = TextEditingController();
    final place = TextEditingController();
    DateTime date = DateTime.now();

    final ok = await uiSheet<bool>(
      context,
      title: 'موعد جديد',
      child: StatefulBuilder(
        builder: (context, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'عنوان الموعد *', controller: title, hint: 'اجتماع مجلس الإدارة'),
            Row(
              children: [
                Expanded(
                  child: Text('التاريخ: ${date.toIso8601String().split('T').first}',
                      style: TextStyle(fontSize: 13, color: App.of(context).sub)),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100));
                    if (picked != null) setSheet(() => date = picked);
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('اختيار'),
                ),
              ],
            ),
            UiField(label: 'الوقت', controller: time, hint: '10:00'),
            UiField(label: 'المكان', controller: place, hint: 'مقر الصندوق'),
            UiButton(
              text: 'إضافة الموعد',
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                try {
                  await context.read<DataController>().createEvent(
                        title: title.text.trim(),
                        eventDate: date.toIso8601String().split('T').first,
                        eventTime: time.text.trim().isEmpty ? null : time.text.trim(),
                        place: place.text.trim().isEmpty ? null : place.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context, true);
                } on ApiException catch (e) {
                  if (context.mounted) uiToast(context, e.message, error: true);
                }
              },
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) uiToast(context, 'تمت إضافة الموعد', success: true);
  }
}
