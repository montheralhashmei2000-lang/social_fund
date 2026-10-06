import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AdminUser>? users;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<DataController>().users(force: true);
      if (mounted) setState(() => users = list);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  Future<void> _add() async {
    final username = TextEditingController();
    final password = TextEditingController();
    final fullName = TextEditingController();
    final phone = TextEditingController();
    String role = 'viewer';

    await uiSheet(
      context,
      title: 'مستخدم جديد',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiField(label: 'اسم المستخدم *', controller: username, hint: 'username'),
          UiField(label: 'كلمة المرور * (8 أحرف على الأقل)', controller: password, obscure: true),
          UiField(label: 'الاسم الكامل *', controller: fullName),
          UiField(label: 'رقم الهاتف (لرمز OTP)', controller: phone, keyboardType: TextInputType.phone),
          UiDropdown<String>(
            label: 'الدور *',
            value: role,
            items: Rbac.labels.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => role = v ?? role,
          ),
          UiButton(
            text: 'إنشاء المستخدم',
            onPressed: () async {
              if (username.text.trim().isEmpty ||
                  password.text.length < 8 ||
                  fullName.text.trim().isEmpty) {
                uiToast(context, 'أكمل الحقول: اسم مستخدم، كلمة مرور 8+ أحرف، الاسم', error: true);
                return;
              }
              try {
                await context.read<DataController>().createUser(
                      username: username.text.trim(),
                      password: password.text,
                      fullName: fullName.text.trim(),
                      role: role,
                      phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                    );
                if (mounted) {
                  Navigator.pop(context);
                  _load();
                  uiToast(context, 'تم إنشاء المستخدم', success: true);
                }
              } on ApiException catch (e) {
                if (mounted) uiToast(context, e.message, error: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _edit(AdminUser u) async {
    final fullName = TextEditingController(text: u.fullName);
    final phone = TextEditingController(text: u.phone ?? '');
    String role = u.role;
    bool active = u.isActive;

    await uiSheet(
      context,
      title: 'تعديل: ${u.username}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiField(label: 'الاسم الكامل', controller: fullName),
          UiField(label: 'رقم الهاتف', controller: phone, keyboardType: TextInputType.phone),
          UiDropdown<String>(
            label: 'الدور',
            value: role,
            items: Rbac.labels.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => role = v ?? role,
          ),
          Row(
            children: [
              const Text('الحساب مفعل'),
              const Spacer(),
              Switch(value: active, activeThumbColor: App.of(context).primary, onChanged: (v) => active = v),
            ],
          ),
          UiButton(
            text: 'حفظ التعديلات',
            onPressed: () async {
              try {
                await context.read<DataController>().updateUser(u.id, {
                  'full_name': fullName.text.trim(),
                  'phone': phone.text.trim().isEmpty ? null : phone.text.trim(),
                  'role': role,
                  'is_active': active,
                });
                if (mounted) {
                  Navigator.pop(context);
                  _load();
                  uiToast(context, 'تم تحديث بيانات المستخدم', success: true);
                }
              } on ApiException catch (e) {
                if (mounted) uiToast(context, e.message, error: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _delete(AdminUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('تعطيل وحذف حساب "${u.username}"؟ لن يتمكن من الدخول بعد الآن.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<DataController>().deleteUser(u.id);
      _load();
      if (mounted) uiToast(context, 'تم حذف المستخدم', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final list = users;

    return Stack(
      children: [
        if (list == null)
          const LoadingView()
        else if (list.isEmpty)
          const Center(child: EmptyState(icon: Icons.manage_accounts, text: 'لا يوجد مستخدمون'))
        else
          ListView(
            padding: const EdgeInsets.all(16),
            children: list.map((u) => UiCard(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: u.isActive ? c.primary.withValues(alpha: 0.1) : c.mu.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          u.fullName.isNotEmpty ? u.fullName[0] : '?',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: u.isActive ? c.primary : c.mu),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${u.fullName} (@${u.username})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
                            Text(
                              '${Rbac.label(u.role)} · ${u.isActive ? "نشط" : "معطل"}'
                              '${u.phone != null ? " · ${u.phone}" : ""}',
                              style: TextStyle(fontSize: 11.5, color: c.mu),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 19, color: c.primary),
                        onPressed: () => _edit(u),
                      ),
                      if (u.username != 'admin')
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 19, color: c.err),
                          onPressed: () => _delete(u),
                        ),
                    ],
                  ),
                )).toList(),
          ),
        Positioned(
          bottom: 18,
          left: 18,
          child: FloatingActionButton(
            onPressed: _add,
            backgroundColor: c.primaryMid,
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<AuditEntry>? logs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final l = await context.read<DataController>().auditLogs();
      if (mounted) setState(() => logs = l);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    }
  }

  IconData _icon(String action) => switch (action) {
        'create' || 'login' => Icons.add_circle_outline,
        'update' => Icons.edit_outlined,
        'delete' || 'logout' => Icons.remove_circle_outline,
        'export' => Icons.download,
        'restore' => Icons.restore,
        'sync_push' => Icons.sync,
        _ => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final list = logs;
    return RefreshIndicator(
      color: c.primary,
      onRefresh: () async {
        await _load();
      },
      child: list == null
          ? const LoadingView()
          : list.isEmpty
              ? ListView(children: const [EmptyState(icon: Icons.history_edu, text: 'لا توجد عمليات مسجلة')])
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: list.map((e) => UiCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_icon(e.action), size: 20, color: c.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.summary ?? '${e.action} ${e.resourceType}',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: c.tx)),
                                  Text(
                                    '${e.userName ?? "-"} · ${e.action} · ${e.timestamp.split('.').first}',
                                    style: TextStyle(fontSize: 10.5, color: c.mu),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ),
    );
  }
}
