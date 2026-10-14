import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/num_parse.dart';
import '../core/rbac.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';
import '../state/controllers.dart';
import '../state/settings_controller.dart';
import '../widgets/ui.dart';
import '../widgets/ui_kit.dart';
import 'currencies_screen.dart';
import 'servers_screen.dart';
import 'settings_sections.dart';

/// شاشة قسم إعدادات: حقول قابلة للتحرير تُحفظ دفعة واحدة، وروابط مباشرة للشاشات
/// المتأثرة بهذه الإعدادات. تُفتح من مركز الإعدادات أو من أيقونة ⚙ في رأس كل شاشة.
class SettingsSectionScreen extends StatefulWidget {
  final String sectionId;
  const SettingsSectionScreen({super.key, required this.sectionId});

  @override
  State<SettingsSectionScreen> createState() => _SettingsSectionScreenState();
}

class _SettingsSectionScreenState extends State<SettingsSectionScreen> {
  late final SettingsSectionDef section = settingsSectionById(widget.sectionId)!;
  late Map<String, Object?> draft;
  late Map<String, Object?> original;
  final Map<String, TextEditingController> _text = {};
  final Map<String, TextEditingController> _addCtl = {};
  List<Account> _accounts = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    original = {for (final f in section.fields) f.key: _clone(s.values[f.key])};
    draft = {for (final e in original.entries) e.key: _clone(e.value)};
    for (final f in section.fields) {
      if (f.kind == SettingKind.number || f.kind == SettingKind.text) {
        _text[f.key] = TextEditingController(text: _show(draft[f.key]));
      }
      if (f.kind == SettingKind.list) _addCtl[f.key] = TextEditingController();
    }
    if (section.fields.any((f) => f.kind == SettingKind.account)) _loadAccounts();
  }

  @override
  void dispose() {
    for (final c in [..._text.values, ..._addCtl.values]) {
      c.dispose();
    }
    super.dispose();
  }

  static Object? _clone(Object? v) => v is List ? List<String>.from(v) : v;

  static String _show(Object? v) {
    if (v == null) return '';
    if (v is num) return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return v.toString();
  }

  Future<void> _loadAccounts() async {
    try {
      final all = await ApiService.instance.accounts();
      if (mounted) setState(() => _accounts = all.where((a) => a.isLiquid && a.isActive).toList());
    } on ApiException {
      // تبقى القائمة فارغة: يظهر خيار «الافتراضي» فقط
    }
  }

  bool _changed(String k) {
    final a = draft[k], b = original[k];
    if (a is List && b is List) return !_listEq(a, b);
    return a != b;
  }

  bool get _dirty => draft.keys.any(_changed);

  Future<void> _save() async {
    final ctl = context.read<SettingsController>();
    final patch = <String, Object?>{
      for (final k in draft.keys)
        if (_changed(k)) k: draft[k],
    };
    if (patch.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ctl.save(patch);
      original = {for (final f in section.fields) f.key: _clone(ctl.values[f.key])};
      draft = {for (final e in original.entries) e.key: _clone(e.value)};
      if (mounted) uiToast(context, 'تم حفظ الإعدادات', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static bool _listEq(List a, List b) => a.length == b.length && a.asMap().entries.every((e) => e.value == b[e.key]);

  void _go(SettingsLink l) {
    if (l.route == 'currencies') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CurrenciesScreen()));
    } else if (l.route == 'servers') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServersScreen()));
    } else if (l.tab != null) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      PushService.openTab.value = l.tab!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<SettingsController>();
    final role = context.read<AuthController>().user?.role;
    final canEdit = Rbac.can(role, 'settings') && ctl.supported;
    final links = section.links.where((l) => Rbac.can(role, l.permission)).toList();

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmDialog(context,
            title: 'تغييرات غير محفوظة', message: 'ستفقد التعديلات التي لم تحفظها. هل تريد الخروج؟',
            confirmText: 'خروج', danger: true, icon: Icons.warning_amber_rounded);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(title: Text(section.title)),
        bottomNavigationBar: canEdit
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: _dirty && !_busy ? _save : null,
                    icon: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label: Text(_dirty ? 'حفظ التغييرات' : 'لا توجد تغييرات'),
                  ),
                ),
              )
            : null,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _intro(c),
            if (!ctl.supported)
              _banner(c, Icons.info_outline, c.warn, 'الخادم الحالي لا يدعم الإعدادات المتقدمة — تُعرض القيم الافتراضية للقراءة فقط.')
            else if (!Rbac.can(role, 'settings'))
              _banner(c, Icons.lock_outline, c.info, 'تعديل هذه الإعدادات لمدير النظام فقط.'),
            for (final f in section.fields) _fieldCard(c, f, canEdit),
            if (links.isNotEmpty) ...[
              const SectionHeader('الشاشات المرتبطة', subtitle: 'تتأثر بهذه الإعدادات'),
              UiCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < links.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: c.border),
                      ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: section.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(links[i].icon, color: section.color, size: 20),
                        ),
                        title: Text(links[i].title),
                        subtitle: Text(links[i].subtitle),
                        trailing: Icon(Icons.chevron_left, color: c.mu),
                        onTap: () => _go(links[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _intro(AppColors c) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [section.color.withValues(alpha: 0.95), section.color.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
              child: Icon(section.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(section.subtitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.5)),
            ),
          ],
        ),
      );

  Widget _banner(AppColors c, IconData icon, Color color, String text) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: c.tx, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _fieldCard(AppColors c, SettingField f, bool canEdit) {
    return UiCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (f.kind == SettingKind.toggle)
            Row(
              children: [
                Expanded(child: _titleBlock(c, f)),
                Switch(
                  value: draft[f.key] == true,
                  onChanged: canEdit ? (v) => setState(() => draft[f.key] = v) : null,
                ),
              ],
            )
          else ...[
            _titleBlock(c, f),
            const SizedBox(height: 10),
            _editor(c, f, canEdit),
          ],
        ],
      ),
    );
  }

  Widget _titleBlock(AppColors c, SettingField f) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.tx)),
          if (f.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(f.subtitle!, style: TextStyle(fontSize: 12, color: c.sub, height: 1.45)),
            ),
        ],
      );

  Widget _editor(AppColors c, SettingField f, bool canEdit) {
    switch (f.kind) {
      case SettingKind.list:
        final items = (draft[f.key] as List).cast<String>();
        final add = _addCtl[f.key]!;
        void commit() {
          final v = add.text.trim();
          if (v.isEmpty || items.contains(v)) return;
          setState(() => draft[f.key] = [...items, v]);
          add.clear();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final it in items)
                  InputChip(
                    label: Text(it),
                    onDeleted: canEdit && items.length > 1
                        ? () => setState(() => draft[f.key] = items.where((x) => x != it).toList())
                        : null,
                  ),
              ],
            ),
            if (canEdit) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: add,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => commit(),
                      decoration: InputDecoration(hintText: f.hint ?? 'إضافة عنصر'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: commit, icon: const Icon(Icons.add), tooltip: 'إضافة'),
                ],
              ),
            ],
          ],
        );
      case SettingKind.number:
        return TextField(
          controller: _text[f.key],
          enabled: canEdit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: f.suffix, hintText: '0'),
          onChanged: (v) => setState(() => draft[f.key] = parseDouble(v) ?? 0),
        );
      case SettingKind.text:
        return TextField(
          controller: _text[f.key],
          enabled: canEdit,
          textDirection: TextDirection.ltr,
          maxLength: 8,
          decoration: InputDecoration(hintText: f.hint, counterText: ''),
          onChanged: (v) => setState(() => draft[f.key] = v.trim()),
        );
      case SettingKind.choice:
        final choices = f.choices!;
        final cur = _show(draft[f.key]);
        return UiDropdown<String>(
          value: choices.containsKey(cur) ? cur : choices.keys.first,
          items: [for (final e in choices.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          onChanged: canEdit
              ? (v) => setState(() => draft[f.key] = f.key.endsWith('month') ? int.parse(v!) : v)
              : (_) {},
        );
      case SettingKind.account:
        final cur = (draft[f.key] as String?) ?? '';
        final ids = _accounts.map((a) => a.id).toSet();
        return UiDropdown<String>(
          value: ids.contains(cur) ? cur : '',
          items: [
            const DropdownMenuItem(value: '', child: Text('الافتراضي (الصندوق 1100)')),
            for (final a in _accounts) DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}')),
          ],
          onChanged: canEdit ? (v) => setState(() => draft[f.key] = v ?? '') : (_) {},
        );
      case SettingKind.toggle:
        return const SizedBox.shrink();
    }
  }
}
