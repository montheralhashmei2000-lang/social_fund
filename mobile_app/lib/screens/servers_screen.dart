import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/server_profiles.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

/// إدارة الخوادم: إضافة خادم محلي/سحابي والتبديل بينها بلا إعادة بناء التطبيق.
/// التبديل يُنهي الجلسة الحالية لأن رموز الدخول خاصة بكل خادم.
class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  Future<void> _select(ServerProfile s) async {
    if (s.id == ServerProfiles.activeId) return;
    final auth = context.read<AuthController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('التبديل إلى خادم آخر'),
        content: Text('سيتم تسجيل خروجك من الخادم الحالي والاتصال بـ «${s.name}».'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تبديل')),
        ],
      ),
    );
    if (ok != true) return;
    await ServerProfiles.select(s.id);
    await auth.onServerChanged();
    if (mounted) setState(() {});
  }

  Future<void> _delete(ServerProfile s) async {
    if (ServerProfiles.all.length <= 1) {
      uiToast(context, 'يجب أن يبقى خادم واحد على الأقل', error: true);
      return;
    }
    final auth = context.read<AuthController>();
    final wasActive = s.id == ServerProfiles.activeId;
    await ServerProfiles.remove(s.id);
    if (wasActive) await auth.onServerChanged();
    if (mounted) setState(() {});
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final url = TextEditingController(text: 'http://192.168.');
    String? err;
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('إضافة خادم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم (مثل: المكتب، السحابة)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: url,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'https://example.com  أو  http://192.168.1.50:8000',
                  errorText: err,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'http مسموح للشبكة المحلية فقط (192.168.x.x ، 10.x.x.x). '
                'خوادم الإنترنت يجب أن تكون https.',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () async {
                try {
                  await ServerProfiles.add(name.text, url.text);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } on FormatException catch (e) {
                  setD(() => err = e.message);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    url.dispose();
    if (added == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الخوادم')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('إضافة خادم'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        children: [
          for (final s in ServerProfiles.all)
            Card(
              child: ListTile(
                leading: Icon(
                  s.id == ServerProfiles.activeId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: s.id == ServerProfiles.activeId ? c.ok : c.sub,
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(s.url, textDirection: TextDirection.ltr),
                onTap: () => _select(s),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: c.err),
                  onPressed: () => _delete(s),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
