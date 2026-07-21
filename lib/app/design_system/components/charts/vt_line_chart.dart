import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';

// A line-over-time chart for a single metric (issue #101 - body weight trend). Owned
// as a CustomPainter rather than pulled from a package, the same call VTBarChart and
// VTMacroRing make. Unlike the bar chart it auto-scales the y-axis to the data's own
// [min, max] with a little padding instead of anchoring at zero: a weight going
// 75 -> 73 kg is the whole story, and a zero baseline would flatten it into a
// featureless line near the top.
class VTLineChart extends StatelessWidget {
  const VTLineChart({required this.points, this.lineColor, this.height = 180, this.semanticLabel, super.key});

  final List<VTLineChartPoint> points;
  final Color? lineColor;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final line = lineColor ?? colorScheme.primary;
    return VTSemanticSummary(
      label: semanticLabel,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(points.length),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) => SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              points: points,
              progress: progress,
              lineColor: line,
              gridColor: colorScheme.onSurface.withValues(alpha: 0.08),
              labelColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points, required this.progress, required this.lineColor, required this.gridColor, required this.labelColor});

  final List<VTLineChartPoint> points;
  final double progress;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  static const double _yLabelWidth = 44;
  static const double _xLabelGutter = 20;
  static const double _dotRadius = 3;
  static const double _valuePadFactor = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }
    final plotWidth = size.width - _yLabelWidth;
    final plotHeight = size.height - _xLabelGutter;
    if (plotWidth <= 0 || plotHeight <= 0) {
      return;
    }

    final values = [for (final point in points) point.value];
    final rawMin = values.reduce(math.min);
    final rawMax = values.reduce(math.max);
    final span = rawMax - rawMin;
    final pad = span == 0 ? math.max(rawMax.abs() * _valuePadFactor, 1) : span * _valuePadFactor;
    final minValue = rawMin - pad;
    final maxValue = rawMax + pad;
    final range = maxValue - minValue;

    double xFor(int index) => points.length == 1 ? plotWidth / 2 : plotWidth * index / (points.length - 1);
    double yFor(double value) => plotHeight * (1 - (value - minValue) / range);

    _paintGridAndYLabels(canvas, plotWidth: plotWidth, plotHeight: plotHeight, minValue: minValue, maxValue: maxValue);

    final offsets = [for (final (index, point) in points.indexed) Offset(xFor(index), yFor(point.value))];

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, plotWidth * progress + 0.5, size.height));
    _paintArea(canvas, offsets, plotHeight: plotHeight);
    _paintLine(canvas, offsets);
    for (final offset in offsets) {
      canvas.drawCircle(offset, _dotRadius, Paint()..color = lineColor);
    }
    canvas.restore();

    _paintXLabels(canvas, plotWidth: plotWidth, plotHeight: plotHeight);
  }

  void _paintArea(Canvas canvas, List<Offset> offsets, {required double plotHeight}) {
    if (offsets.length < 2) {
      return;
    }
    final path = Path()..moveTo(offsets.first.dx, plotHeight);
    for (final offset in offsets) {
      path.lineTo(offset.dx, offset.dy);
    }
    path
      ..lineTo(offsets.last.dx, plotHeight)
      ..close();
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: 0.20), lineColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, offsets.last.dx, plotHeight));
    canvas.drawPath(path, fill);
  }

  void _paintLine(Canvas canvas, List<Offset> offsets) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (offsets.length == 1) {
      canvas.drawCircle(offsets.first, _dotRadius + 1, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _paintGridAndYLabels(Canvas canvas, {required double plotWidth, required double plotHeight, required double minValue, required double maxValue}) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas
      ..drawLine(Offset.zero, Offset(plotWidth, 0), grid)
      ..drawLine(Offset(0, plotHeight), Offset(plotWidth, plotHeight), grid);
    _paintText(canvas, maxValue.round().toString(), Offset(plotWidth + 6, -2), align: TextAlign.left);
    _paintText(canvas, minValue.round().toString(), Offset(plotWidth + 6, plotHeight - 12), align: TextAlign.left);
  }

  void _paintXLabels(Canvas canvas, {required double plotWidth, required double plotHeight}) {
    final firstLabel = points.first.label;
    final lastLabel = points.last.label;
    if (firstLabel != null) {
      _paintText(canvas, firstLabel, Offset(0, plotHeight + 4), align: TextAlign.left);
    }
    if (lastLabel != null && points.length > 1) {
      _paintText(canvas, lastLabel, Offset(plotWidth, plotHeight + 4), align: TextAlign.right, width: plotWidth);
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset, {required TextAlign align, double? width}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 11),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width ?? _yLabelWidth);
    final dx = align == TextAlign.right ? offset.dx - painter.width : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.points != points || oldDelegate.lineColor != lineColor;
}
