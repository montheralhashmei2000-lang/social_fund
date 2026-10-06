import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/currency.dart';
import '../core/num_parse.dart';
import '../core/theme.dart';
import '../state/currency_controller.dart';
import '../widgets/ui.dart';

/// إدارة العملات وأسعار الصرف (للمدير): إضافة عملة، تحديث السعر مع سجل تاريخي،
/// تفعيل/تعطيل، واختيار العملة المحلية (عملة الدفاتر) والافتراضية للنظام.
class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({super.key});

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyController>().load(includeInactive: true);
    });
  }

  Future<void> _run(Future<void> Function() action, String okMsg) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) uiToast(context, okMsg, success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذّر تنفيذ العملية', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('رجوع')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد')),
        ],
      ),
    );
    return ok == true && mounted;
  }

  Future<void> _editRate(Currency cur) async {
    final ctl = context.read<CurrencyController>();
    final local = ctl.local;
    final rate = TextEditingController(text: cur.rate > 0 ? cur.rate.toString() : '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('سعر ${cur.code}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('كم ${local?.symbol ?? 'وحدة محلية'} تساوي 1 ${cur.code}؟'),
            const SizedBox(height: 10),
            TextField(
              controller: rate,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'مثال: 2530', suffixText: local?.symbol),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );
    final v = parseDouble(rate.text);
    rate.dispose();
    if (ok != true || !mounted) return;
    if (v == null || v <= 0) {
      uiToast(context, 'أدخل سعراً صحيحاً أكبر من صفر', error: true);
      return;
    }
    await _run(() => ctl.save({'name_ar': cur.nameAr, 'symbol': cur.symbol, 'decimals': cur.decimals, 'rate': v},
        existingCode: cur.code), 'تم تحديث السعر');
  }

  Future<void> _history(Currency cur) async {
    final ctl = context.read<CurrencyController>();
    List<Map<String, dynamic>> rows = [];
    try {
      rows = await ctl.history(cur.code);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
      return;
    }
    if (!mounted) return;
    final f = NumberFormat('#,##0.####');
    await uiSheet(
      context,
      title: 'سجل أسعار ${cur.code}',
      child: rows.isEmpty
          ? const EmptyState(icon: Icons.history, text: 'لا توجد تغييرات مسجلة')
          : Column(
              children: [
                for (final r in rows)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.show_chart, size: 18),
                    title: Text(f.format(r['rate'] as num)),
                    subtitle: Text('${r['at']}'.split('.').first.replaceFirst('T', ' ')),
                  ),
              ],
            ),
    );
  }

  Future<void> _add() async {
    final ctl = context.read<CurrencyController>();
    final code = TextEditingController();
    final name = TextEditingController();
    final symbol = TextEditingController();
    final rate = TextEditingController();
    int decimals = 2;
    await uiSheet(
      context,
      title: 'إضافة عملة',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'رمز العملة (3 أحرف) *', controller: code, hint: 'EUR'),
            UiField(label: 'الاسم *', controller: name, hint: 'يورو'),
            UiField(label: 'الرمز المختصر *', controller: symbol, hint: '€'),
            UiDropdown<int>(
              label: 'الخانات العشرية',
              value: decimals,
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (v) => setSheet(() => decimals = v ?? 2),
            ),
            UiField(
              label: 'سعر الصرف (بالعملة المحلية) *',
              controller: rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            UiButton(
              text: 'إضافة وتفعيل',
              onPressed: () async {
                final r = parseDouble(rate.text);
                if (code.text.trim().length != 3 || name.text.trim().isEmpty || symbol.text.trim().isEmpty || r == null || r <= 0) {
                  uiToast(ctx, 'أكمل الحقول بسعر صحيح', error: true);
                  return;
                }
                try {
                  await ctl.save({
                    'code': code.text.trim().toUpperCase(),
                    'name_ar': name.text.trim(),
                    'symbol': symbol.text.trim(),
                    'decimals': decimals,
                    'rate': r,
                    'is_active': true,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                } on ApiException catch (e) {
                  if (ctx.mounted) uiToast(ctx, e.message, error: true);
                } catch (_) {
                  if (ctx.mounted) uiToast(ctx, 'تعذّرت الإضافة', error: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<CurrencyController>();
    final local = ctl.local;
    final f = NumberFormat('#,##0.####');

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('العملات وأسعار الصرف'), backgroundColor: c.primaryDark),
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.primaryMid,
        onPressed: _busy ? null : _add,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: !ctl.loaded && ctl.all.isEmpty
          ? (ctl.lastError != null
              ? EmptyState(icon: Icons.cloud_off, text: ctl.lastError!)
              : const LoadingView())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                UiCard(
                  child: Text(
                    'العملة المحلية هي عملة الدفاتر: كل الإجماليات والقيود تُحفظ بها. '
                    'المبالغ بعملة أخرى تُحوَّل بسعر الصرف الحالي لحظة التسجيل ويُحفظ المبلغ الأصلي مع السعر. '
                    'تغيير السعر لا يعدّل المعاملات السابقة.',
                    style: TextStyle(fontSize: 12, color: c.sub, height: 1.5),
                  ),
                ),
                for (final cur in ctl.all)
                  UiCard(
                    accentRight: cur.isLocal ? c.gold : (cur.isActive ? c.primary : c.mu),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${cur.nameAr} (${cur.code})',
                                  style: AppTheme.sectionTitle(c, size: 14.5)),
                            ),
                            if (cur.isLocal) const UiBadge('محلية'),
                            if (cur.isDefault) ...[const SizedBox(width: 4), const UiBadge('افتراضية')],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cur.isLocal
                              ? 'عملة الدفاتر - السعر 1'
                              : (cur.rate > 0
                                  ? '1 ${cur.code} = ${f.format(cur.rate)} ${local?.symbol ?? ''}'
                                  : 'لا يوجد سعر صرف'),
                          style: TextStyle(fontSize: 12.5, color: c.sub),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (!cur.isLocal)
                              TextButton.icon(
                                onPressed: _busy ? null : () => _editRate(cur),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('السعر'),
                              ),
                            TextButton.icon(
                              onPressed: _busy ? null : () => _history(cur),
                              icon: const Icon(Icons.history, size: 16),
                              label: const Text('السجل'),
                            ),
                            if (cur.isActive && !cur.isDefault)
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => _run(() => ctl.setConfig(defaultCode: cur.code), 'تم تعيين الافتراضية'),
                                child: const Text('اجعلها افتراضية'),
                              ),
                            if (cur.isActive && !cur.isLocal)
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () async {
                                        if (!await _confirm('تغيير العملة المحلية؟',
                                            'ستصبح ${cur.nameAr} عملة الدفاتر وتُعاد نسبة أسعار بقية العملات إليها. المبالغ المخزنة سابقاً لا تتغير أرقامها وستُفسَّر بالعملة الجديدة، فلا تفعل هذا إلا في بداية التشغيل.')) {
                                          return;
                                        }
                                        await _run(() => ctl.setConfig(local: cur.code), 'تم تغيير العملة المحلية');
                                      },
                                child: const Text('اجعلها محلية'),
                              ),
                            if (!cur.isLocal && !cur.isDefault)
                              Switch(
                                value: cur.isActive,
                                activeThumbColor: c.primary,
                                onChanged: _busy
                                    ? null
                                    : (v) => _run(
                                        () => ctl.save({
                                              'name_ar': cur.nameAr,
                                              'symbol': cur.symbol,
                                              'decimals': cur.decimals,
                                              'is_active': v,
                                            }, existingCode: cur.code),
                                        v ? 'تم التفعيل' : 'تم التعطيل'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
