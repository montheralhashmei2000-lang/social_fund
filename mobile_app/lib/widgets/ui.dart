import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/currency.dart';
import '../core/theme.dart';

/// يُعرض بعملة العرض المختارة (CurrencyFormat)، وقبل تحميل العملات: ريال بلا كسور.
String money(num v) => CurrencyFormat.format(v);

/// مبالغ عشرية (محاسبة) بفاصلة عشرية ذكية.
String money2(num v) => v.truncateToDouble() == v ? money(v) : '${NumberFormat('#,##0.00').format(v)} ﷼';

Color statusColor(String status, AppColors c) {
  switch (status) {
    case 'نشط':
    case 'معتمدة':
    case 'قبض':
    case 'معتمد':
      return c.ok;
    case 'معلق':
    case 'قيد المراجعة':
      return c.warn;
    case 'مصروفة':
      return c.info;
    case 'مرفوضة':
    case 'صرف':
      return c.err;
    default:
      return c.primary;
  }
}

class UiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? accentRight;

  const UiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.accentRight,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color ?? c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: accentRight == null
                    ? BorderSide.none
                    : BorderSide(color: accentRight!, width: 3),
              ),
            ),
            padding: padding ?? const EdgeInsets.all(14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class UiBadge extends StatelessWidget {
  final String text;
  const UiBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final color = statusColor(text, c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class UiButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final String variant; // primary | gold | danger | ghost | outline
  final bool small;

  const UiButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.variant = 'primary',
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final (bg, fg) = switch (variant) {
      'gold' => (c.gold, c.primaryDark),
      'danger' => (c.err, Colors.white),
      'ghost' => (c.surf, c.sub),
      'outline' => (Colors.transparent, c.primary),
      _ => (c.primaryMid, Colors.white),
    };
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: variant == 'outline' ? BorderSide(color: c.primary, width: 1.4) : null,
          padding: EdgeInsets.symmetric(vertical: small ? 10 : 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.w700),
        ),
        child: child ?? Text(text ?? ''),
      ),
    );
  }
}

/// حقل إدخال بعنوان وأيقونة (يحاكي Field في النسخة السابقة).
class UiField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const UiField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(label!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.sub)),
            ),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            style: TextStyle(color: c.tx),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, size: 19, color: c.mu),
              suffixIcon: suffix,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// قائمة منسدلة بعنوان.
class UiDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const UiDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(label!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.sub)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: c.card,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// ورقة سفلية موحدة (تعويض Sheet في النسخة السابقة).
Future<T?> uiSheet<T>(BuildContext context, {required String title, required Widget child, Color? accent}) {
  final c = App.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: MediaQuery.of(ctx).viewInsets,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.92),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: accent ?? c.primary)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, size: 20, color: c.mu),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// تمرير رسالة تنبيه موحدة.
void uiToast(BuildContext context, String message, {bool error = false, bool success = false}) {
  final c = App.of(context);
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: error ? c.err : (success ? c.ok : c.primaryDark),
      duration: const Duration(seconds: 3),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState({super.key, this.icon = Icons.inbox_outlined, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(icon, size: 42, color: c.border),
            const SizedBox(height: 10),
            Text(text, style: TextStyle(color: c.mu, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(color: c.primaryMid),
      ),
    );
  }
}

/// الوصول السريع للوحة الألوان داخل شجرة الواجهات.
class App extends InheritedWidget {
  final AppColors colors;

  const App({super.key, required this.colors, required super.child});

  static AppColors of(BuildContext context) {
    final app = context.dependOnInheritedWidgetOfExactType<App>();
    return app?.colors ?? (MediaQuery.platformBrightnessOf(context) == Brightness.dark ? AppColors.dark : AppColors.light);
  }

  @override
  bool updateShouldNotify(App oldWidget) => oldWidget.colors != colors;
}
