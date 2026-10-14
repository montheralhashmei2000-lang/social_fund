import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/currency.dart' show MoneyOrigin;
import '../core/theme.dart';
import 'ui.dart';

/// أدوات واجهة مشتركة: جداول، حالات (فارغ/خطأ/تحميل)، نوافذ تأكيد، بطاقات إحصاء، بحث وفلاتر.
/// تُبنى فوق سمة التطبيق (theme.dart) فتتبع الوضع الداكن والخطوط تلقائياً.

// ───────────────────────── عناوين المقاطع ─────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader(this.title,
      {super.key, this.subtitle, this.trailing, this.padding = const EdgeInsets.fromLTRB(4, 14, 4, 8)});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(width: 22, height: 3, decoration: BoxDecoration(color: c.gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.sectionTitle(c, size: 15.5)),
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 11.5, color: c.mu)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ───────────────────────── المبالغ والإحصاءات ─────────────────────────

/// مبلغ بنمط محاسبي (أرقام بعرض ثابت) ولون حسب الإشارة اختيارياً.
class AmountText extends StatelessWidget {
  final num amount;
  final double size;
  final Color? color;
  final bool signed; // + للموجب و − للسالب بألوان ok/err
  final FontWeight? weight;

  const AmountText(this.amount, {super.key, this.size = 14, this.color, this.signed = false, this.weight});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    var col = color ?? c.tx;
    var text = money(amount.abs());
    if (signed && amount != 0) {
      col = amount > 0 ? c.ok : c.err;
      text = '${amount > 0 ? '+' : '−'} $text';
    } else if (amount < 0) {
      text = '− $text';
    }
    return Text(text,
        textDirection: TextDirection.rtl, style: AppTheme.amount(c, size: size, color: col, weight: weight));
  }
}

/// بطاقة إحصاء صغيرة: أيقونة، قيمة كبيرة، تسمية، وسطر ثانوي اختياري.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color color;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return UiCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: c.sub, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: AppTheme.amount(c, size: 20, color: c.tx)),
          ),
          // السطر الثانوي يُحجز دائماً ليتساوى ارتفاع البطاقات المتجاورة
          Padding(padding: const EdgeInsets.only(top: 2), child: Text(sub ?? ' ', style: TextStyle(fontSize: 11, color: c.mu))),
        ],
      ),
    );
  }
}

// ───────────────────────── الحالات: خطأ / تحميل / فارغ ─────────────────────────

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: c.err.withValues(alpha: 0.7)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.sub, fontSize: 13.5)),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة المحاولة')),
            ],
          ],
        ),
      ),
    );
  }
}

/// هيكل تحميل نابض بدل الدائرة الدوارة: يُظهر شكل المحتوى القادم.
class SkeletonList extends StatefulWidget {
  final int count;
  final double itemHeight;
  const SkeletonList({super.key, this.count = 5, this.itemHeight = 84});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) {
        final t = 0.35 + 0.35 * _ctl.value;
        return Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                height: widget.itemHeight,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bar(c, t, 0.5, 12),
                    const SizedBox(height: 10),
                    _bar(c, t, 0.8, 10),
                    const SizedBox(height: 8),
                    _bar(c, t, 0.35, 10),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _bar(AppColors c, double t, double factor, double h) => FractionallySizedBox(
        widthFactor: factor,
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          height: h,
          decoration: BoxDecoration(color: c.border.withValues(alpha: t), borderRadius: BorderRadius.circular(6)),
        ),
      );
}

// ───────────────────────── نوافذ ─────────────────────────

/// نافذة تأكيد موحدة. تعيد true عند التأكيد.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'تأكيد',
  String cancelText = 'إلغاء',
  bool danger = false,
  IconData? icon,
}) async {
  final c = App.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: icon == null ? null : Icon(icon, size: 34, color: danger ? c.err : c.primary),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelText)),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: c.err) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return ok == true;
}

// ───────────────────────── بحث وفلاتر ─────────────────────────

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  const SearchField({super.key, this.hint = 'بحث…', required this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search, color: c.mu),
        fillColor: c.card,
      ),
    );
  }
}

/// صف رقائق فلترة أفقي قابل للتمرير مع عدّاد اختياري لكل خيار.
class FilterChipsBar extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int>? counts;
  const FilterChipsBar({super.key, required this.options, required this.selected, required this.onSelected, this.counts});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i];
          final sel = o == selected;
          final n = counts?[o];
          return ChoiceChip(
            selected: sel,
            showCheckmark: false,
            label: Text(n == null ? o : '$o · $n'),
            labelStyle: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : c.sub),
            selectedColor: c.isDark ? c.primaryMid : c.primary,
            backgroundColor: c.card,
            side: BorderSide(color: sel ? Colors.transparent : c.border),
            onSelected: (_) => onSelected(o),
          );
        },
      ),
    );
  }
}

// ───────────────────────── الجداول ─────────────────────────

class AppColumn {
  final String label;
  final bool numeric;
  final double minWidth;
  final int flex;
  const AppColumn(this.label, {this.numeric = false, this.minWidth = 90, this.flex = 1});
}

class AppRow {
  /// كل خلية: نص/رقم أو Widget.
  final List<Object?> cells;

  /// مفاتيح الفرز لكل عمود (اختيارية؛ إن غابت يُفرز بنص الخلية).
  final List<Comparable?>? sortKeys;
  final VoidCallback? onTap;
  final Color? tint;
  const AppRow(this.cells, {this.sortKeys, this.onTap, this.tint});
}

/// جدول بيانات متجاوب: رأس ثابت، صفوف مخططة، فرز بالنقر على العنوان، صف إجماليات،
/// وتمرير أفقي تلقائي عندما تضيق الشاشة. للأرقام المحاسبية يعرض بخط ثابت العرض.
class AppDataTable extends StatefulWidget {
  final List<AppColumn> columns;
  final List<AppRow> rows;
  final List<Object?>? footer;
  final String emptyText;
  final int? initialSortColumn;
  final bool initialAscending;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.footer,
    this.emptyText = 'لا توجد بيانات',
    this.initialSortColumn,
    this.initialAscending = true,
  });

  @override
  State<AppDataTable> createState() => _AppDataTableState();
}

class _AppDataTableState extends State<AppDataTable> {
  int? _sortCol;
  bool _asc = true;

  @override
  void initState() {
    super.initState();
    _sortCol = widget.initialSortColumn;
    _asc = widget.initialAscending;
  }

  List<AppRow> get _sorted {
    final col = _sortCol;
    if (col == null) return widget.rows;
    final list = [...widget.rows];
    int cmp(AppRow a, AppRow b) {
      Comparable? ka = (a.sortKeys != null && col < a.sortKeys!.length) ? a.sortKeys![col] : _textOf(a.cells[col]);
      Comparable? kb = (b.sortKeys != null && col < b.sortKeys!.length) ? b.sortKeys![col] : _textOf(b.cells[col]);
      if (ka == null && kb == null) return 0;
      if (ka == null) return 1;
      if (kb == null) return -1;
      return ka.compareTo(kb);
    }

    list.sort((a, b) => _asc ? cmp(a, b) : cmp(b, a));
    return list;
  }

  static Comparable? _textOf(Object? o) {
    if (o is num) return o;
    if (o is String) return o;
    return null;
  }

  List<double> _widths(double available) {
    final cols = widget.columns;
    final minTotal = cols.fold<double>(0, (s, c) => s + c.minWidth);
    final extra = math.max(0, available - minTotal);
    final flexTotal = cols.fold<int>(0, (s, c) => s + c.flex);
    return [for (final c in cols) c.minWidth + extra * c.flex / flexTotal];
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final rows = _sorted;
    return LayoutBuilder(builder: (context, box) {
      // الحاوية بحدّ 1px من كل جهة: العرض المتاح للأعمدة أقل منه بـ2 (وإلا فيض 2px)
      final available = box.maxWidth - 2;
      final widths = _widths(available);
      final total = widths.fold<double>(0, (s, w) => s + w);
      final table = SizedBox(
        width: total,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerRow(c, widths),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text(widget.emptyText, style: TextStyle(color: c.mu, fontSize: 13))),
              )
            else
              for (var i = 0; i < rows.length; i++) _dataRow(c, rows[i], widths, i),
            if (widget.footer != null) _footerRow(c, widths),
          ],
        ),
      );
      return Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: c.border.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: total > available + 0.5
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: table)
            : table,
      );
    });
  }

  Widget _cell(AppColors c, Object? v, AppColumn col, double w, {bool header = false, bool bold = false}) {
    Widget child;
    if (v is Widget) {
      child = v;
    } else {
      final text = v == null ? '—' : (v is num ? _fmt(v) : v.toString());
      child = Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textDirection: col.numeric ? TextDirection.rtl : null,
        style: col.numeric && !header
            ? AppTheme.amount(c, size: 13, weight: bold ? FontWeight.w900 : FontWeight.w600)
            : TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: header ? 12 : 13,
                fontWeight: header || bold ? FontWeight.w800 : FontWeight.w500,
                color: header ? c.sub : c.tx),
      );
    }
    return SizedBox(
      width: w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Align(alignment: col.numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart, child: child),
      ),
    );
  }

  static String _fmt(num v) => money(v).replaceAll(RegExp(r'\s*[^\d.,\-−\s]+\s*$'), '').trim();

  Widget _headerRow(AppColors c, List<double> widths) {
    return Container(
      color: c.surf,
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++)
            InkWell(
              onTap: () => setState(() {
                if (_sortCol == i) {
                  _asc = !_asc;
                } else {
                  _sortCol = i;
                  _asc = true;
                }
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _cell(c, widget.columns[i].label, widget.columns[i], widths[i] - (_sortCol == i ? 18 : 0), header: true),
                  if (_sortCol == i)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: c.gold),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dataRow(AppColors c, AppRow r, List<double> widths, int i) {
    final bg = r.tint ?? (i.isOdd ? c.surf.withValues(alpha: 0.55) : Colors.transparent);
    return InkWell(
      onTap: r.onTap,
      child: Container(
        decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.5)))),
        child: Row(
          children: [
            for (var k = 0; k < widget.columns.length; k++)
              _cell(c, k < r.cells.length ? r.cells[k] : null, widget.columns[k], widths[k]),
          ],
        ),
      ),
    );
  }

  Widget _footerRow(AppColors c, List<double> widths) {
    return Container(
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: c.isDark ? 0.22 : 0.08),
        border: Border(top: BorderSide(color: c.primary.withValues(alpha: 0.5), width: 1.4)),
      ),
      child: Row(
        children: [
          for (var k = 0; k < widget.columns.length; k++)
            _cell(c, k < widget.footer!.length ? widget.footer![k] : null, widget.columns[k], widths[k], bold: true),
        ],
      ),
    );
  }
}

/// سطر صغير تحت المبلغ يبيّن أصله بالعملة الأجنبية وسعر الصرف، مثل: 100 USD @ 2,530.
class OriginNote extends StatelessWidget {
  final MoneyOrigin origin;
  const OriginNote(this.origin, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Text(origin.label,
        textDirection: TextDirection.ltr,
        style: TextStyle(fontSize: 10.5, color: c.mu, fontWeight: FontWeight.w600));
  }
}
