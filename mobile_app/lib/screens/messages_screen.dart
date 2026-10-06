import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final data = context.watch<DataController>();
    final auth = context.watch<AuthController>();
    final me = auth.user!;
    final messages = data.messages;

    return Stack(
      children: [
        if (messages.isEmpty)
          const Center(child: EmptyState(icon: Icons.mail_outline, text: 'لا توجد رسائل بعد'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: messages.map((m) {
              final incoming = m.toUserId == me.id;
              final unread = incoming && !m.read;
              return UiCard(
                onTap: incoming && !m.read ? () => _markRead(m) : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (incoming ? c.primary : c.gold).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (incoming ? m.fromName : m.toName).isNotEmpty
                            ? (incoming ? m.fromName : m.toName)[0]
                            : '?',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: incoming ? c.primary : c.goldDark),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  incoming ? 'من: ${m.fromName}' : 'إلى: ${m.toName}',
                                  style: TextStyle(
                                      fontWeight: unread ? FontWeight.w900 : FontWeight.w700,
                                      fontSize: 13,
                                      color: c.tx),
                                ),
                              ),
                              if (unread)
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(color: c.err, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(m.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: unread ? c.tx : c.sub,
                                  fontWeight: unread ? FontWeight.w700 : FontWeight.w400)),
                        ],
                      ),
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
            onPressed: _compose,
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _markRead(MessageModel m) async {
    try {
      await context.read<DataController>().markMessageRead(m.id);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  Future<void> _compose() async {
    final data = context.read<DataController>();
    List<Colleague> colleagues;
    try {
      colleagues = await data.colleagues();
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
      return;
    }
    if (!mounted) return;
    if (colleagues.isEmpty) {
      uiToast(context, 'لا يوجد زملاء مسجلون لإرسال الرسائل إليهم', error: true);
      return;
    }
    await uiSheet(context, title: 'رسالة جديدة', child: _ComposeForm(colleagues: colleagues));
  }
}

class _ComposeForm extends StatefulWidget {
  final List<Colleague> colleagues;
  const _ComposeForm({required this.colleagues});

  @override
  State<_ComposeForm> createState() => _ComposeFormState();
}

class _ComposeFormState extends State<_ComposeForm> {
  late String toId = widget.colleagues.first.id;
  final body = TextEditingController();
  bool busy = false;
  String? err;

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiDropdown<String>(
          label: 'المستلم *',
          value: toId,
          items: widget.colleagues
              .map((u) => DropdownMenuItem(value: u.id, child: Text('${u.fullName} (${rbacRoleLabel(u.role)})')))
              .toList(),
          onChanged: (v) => setState(() => toId = v ?? toId),
        ),
        UiField(
          label: 'نص الرسالة *',
          controller: body,
          maxLines: 4,
          hint: 'اكتب رسالتك هنا…',
        ),
        if (err != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(err!, style: TextStyle(color: c.err, fontSize: 12)),
          ),
        UiButton(
          text: busy ? 'جارٍ الإرسال…' : 'إرسال الرسالة',
          onPressed: busy
              ? null
              : () async {
                  if (body.text.trim().isEmpty) {
                    setState(() => err = 'اكتب نص الرسالة أولاً');
                    return;
                  }
                  setState(() {
                    busy = true;
                    err = null;
                  });
                  try {
                    await context.read<DataController>().sendMessage(toId, body.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      uiToast(context, 'تم إرسال الرسالة', success: true);
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

String rbacRoleLabel(String role) {
  const m = {
    'admin': 'مدير النظام',
    'accountant': 'محاسب',
    'reviewer': 'مراجع',
    'viewer': 'مراقب',
  };
  return m[role] ?? role;
}
