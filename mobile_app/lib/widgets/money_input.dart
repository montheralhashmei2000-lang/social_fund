import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/currency.dart';
import '../core/num_parse.dart';
import '../state/currency_controller.dart';
import 'ui.dart';

/// قيمة مُدخَلة: [local] بالعملة المحلية (تُرسل كـ amount)، وإن كانت العملة غير
/// المحلية يُرسل أيضاً الأصل لتحسبه الخادم بسعرها هي (المرجع الوحيد).
class MoneyValue {
  final int local;
  final Currency currency;
  final double original;
  final bool foreign;
  const MoneyValue(this.local, this.currency, this.original, this.foreign);

  /// حقول تُضاف إلى جسم الطلب.
  Map<String, dynamic> toPayload() => {
        'amount': local,
        if (foreign) 'currency': currency.code,
        if (foreign) 'original_amount': original,
      };
}

/// متحكم حقل المبلغ: نص المبلغ + العملة المختارة. ابدأ بعملة العرض الحالية.
class MoneyInputController {
  final TextEditingController text = TextEditingController();
  String? currencyCode;

  void dispose() => text.dispose();

  /// يقرأ القيمة ويتحقق منها؛ null إن كانت غير صالحة أو لا سعر للعملة.
  MoneyValue? read(BuildContext context) {
    final cc = context.read<CurrencyController>();
    final cur = _resolve(cc) ?? _fallback;
    final v = parseDouble(text.text);
    if (v == null || v <= 0) return null;
    final isLocal = cur.isLocal;
    final local = isLocal ? v.round() : cur.toLocal(v);
    if (local <= 0) return null;
    return MoneyValue(local, cur, v, !isLocal);
  }

  Currency? _resolve(CurrencyController cc) {
    final code = currencyCode;
    if (code != null) {
      for (final c in cc.active) {
        if (c.code == code) return c;
      }
    }
    return cc.display ?? cc.local;
  }

  /// إن تعذّر تحميل العملات (خادم قديم/انقطاع): الإدخال بالعملة المحلية الافتراضية.
  static const Currency _fallback = Currency(
      code: 'YER', nameAr: 'ريال يمني', symbol: '﷼', decimals: 0, rate: 1,
      isLocal: true, isDefault: true, isActive: true);
}

/// حقل مبلغ مع اختيار العملة ومعاينة التحويل إلى المحلية.
class MoneyInput extends StatefulWidget {
  final MoneyInputController controller;
  final String label;
  const MoneyInput({super.key, required this.controller, this.label = 'المبلغ'});

  @override
  State<MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.text.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.text.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final cc = context.watch<CurrencyController>();
    final active = cc.active;
    final ctl = widget.controller;
    final cur = ctl._resolve(cc) ?? MoneyInputController._fallback;
    final local = cc.local;

    // معاينة التحويل عند عملة غير المحلية
    String? preview;
    if (local != null && !cur.isLocal) {
      final v = parseDouble(ctl.text.text);
      if (v != null && v > 0) {
        preview = '≈ ${local.format(cur.toLocal(v))} بسعر ${cur.rate.toStringAsFixed(cur.rate >= 100 ? 0 : 4)}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (active.length > 1)
          UiDropdown<String>(
            label: 'العملة',
            value: cur.code,
            items: [
              for (final x in active)
                DropdownMenuItem(value: x.code, child: Text('${x.nameAr} (${x.code})')),
            ],
            onChanged: (v) => setState(() => ctl.currencyCode = v),
          ),
        UiField(
          label: '${widget.label} (${cur.symbol}) *',
          controller: ctl.text,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          icon: Icons.payments_outlined,
        ),
        if (preview != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(preview, style: TextStyle(fontSize: 12, color: c.mu)),
          ),
      ],
    );
  }
}
