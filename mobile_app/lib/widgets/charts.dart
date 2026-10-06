import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'ui.dart';

/// رسوم بيانية مرسومة يدوياً بـ CustomPainter (بدون مكتبات خارجية):
/// اتجاه الإيرادات، توزيع دائري، وأعمدة بسيطة.

class TrendPoint {
  final String label;
  final int value;
  const TrendPoint(this.label, this.value);
}

class TrendLineChart extends StatelessWidget {
  final List<TrendPoint> points;
  final double height;

  const TrendLineChart({super.key, required this.points, this.height = 130});

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    if (points.isEmpty) {
      return const SizedBox(height: 130, child: EmptyState(icon: Icons.show_chart, text: 'لا توجد بيانات كافية بعد'));
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TrendPainter(points, c),
        size: Size.infinite,
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TrendPoint> points;
  final AppColors c;
  _TrendPainter(this.points, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final values = points.map((p) => p.value).toList();
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final dx = size.width / math.max(1, points.length - 1);
    double yOf(int v) => size.height - 14 - ((v - minV) / range) * (size.height - 34);

    final line = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width - i * dx; // من اليمين لليسار (RTL)
      final y = yOf(points[i].value);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final fill = Path.from(line)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.ok.withValues(alpha: 0.25), c.ok.withValues(alpha: 0.02)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = c.ok
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    final tp = TextPainter(textDirection: TextDirection.rtl);
    for (var i = 0; i < points.length; i++) {
      final x = size.width - i * dx;
      canvas.drawCircle(Offset(x, yOf(points[i].value)), 3, Paint()..color = c.ok);
      if (points.length <= 13) {
        tp.text = TextSpan(
            text: points[i].label, style: TextStyle(fontSize: 9, color: c.mu));
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.points != points;
}

class DonutSegment {
  final int value;
  final Color color;
  const DonutSegment(this.value, this.color);
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final String centerLabel;
  final String centerSub;

  const DonutChart({
    super.key,
    required this.segments,
    this.size = 104,
    required this.centerLabel,
    required this.centerSub,
  });

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(segments, c),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerLabel,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c.tx)),
              Text(centerSub, style: TextStyle(fontSize: 10, color: c.mu)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final AppColors c;
  _DonutPainter(this.segments, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0, (s, e) => s + e.value);
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = c.border.withValues(alpha: 0.4);
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = (s.value / total) * math.pi * 2;
      paint.color = s.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}

class BarDatum {
  final String label;
  final int value;
  final Color color;
  const BarDatum(this.label, this.value, this.color);
}

class SimpleBarChart extends StatelessWidget {
  final List<BarDatum> bars;
  final double height;

  const SimpleBarChart({super.key, required this.bars, this.height = 100});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bars
            .map((b) => Expanded(
                  child: _BarColumn(b),
                ))
            .toList(),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final BarDatum d;
  const _BarColumn(this.d);

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${d.value}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c.tx)),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 26,
                decoration: BoxDecoration(
                  color: d.color.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(d.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: c.mu)),
        ],
      ),
    );
  }
}

/// أعمدة بنسب حقيقية (الارتفاع نسبة من الأقصى).
class ProportionalBarChart extends StatelessWidget {
  final List<BarDatum> bars;
  final double height;

  const ProportionalBarChart({super.key, required this.bars, this.height = 110});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) return const SizedBox.shrink();
    final maxV = bars.map((b) => b.value).reduce(math.max).clamp(1, 1 << 31).toInt();
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bars
            .map((b) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${b.value}',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800, color: App.of(context).tx)),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: b.value / maxV,
                              child: Container(
                                width: 26,
                                decoration: BoxDecoration(
                                  color: b.color.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(b.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9, color: App.of(context).mu)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
