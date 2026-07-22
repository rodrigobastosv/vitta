import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/charts/vt_chart_tooltip.dart';
import 'package:vitta/app/design_system/components/charts/vt_line_chart_point.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

// A line-over-time chart for a single metric (issue #101 - body weight trend). Owned
// as a CustomPainter rather than pulled from a package, the same call VTBarChart and
// VTMacroRing make. Unlike the bar chart it auto-scales the y-axis to the data's own
// [min, max] with a little padding instead of anchoring at zero: a weight going
// 75 -> 73 kg is the whole story, and a zero baseline would flatten it into a
// featureless line near the top.
class VTLineChart extends StatefulWidget {
  const VTLineChart({required this.points, this.lineColor, this.height = 180, this.semanticLabel, super.key});

  final List<VTLineChartPoint> points;
  final Color? lineColor;
  final double height;
  final String? semanticLabel;

  @override
  State<VTLineChart> createState() => _VTLineChartState();
}

class _VTLineChartState extends State<VTLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(VTLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _selectedIndex = null;
    }
  }

  bool _isTappable(int index) => index >= 0 && index < widget.points.length && widget.points[index].tooltip != null;

  void _handleTapAt(double dx, _LineChartGeometry geometry) {
    if (widget.points.isEmpty) {
      return;
    }
    final index = geometry.nearestIndex(dx);
    setState(() {
      if (_selectedIndex == index || !_isTappable(index)) {
        _selectedIndex = null;
      } else {
        _selectedIndex = index;
        VTHaptics.selection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final line = widget.lineColor ?? colorScheme.primary;
    return VTSemanticSummary(
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final geometry = _LineChartGeometry(points: widget.points, size: Size(width, widget.height));
          final selectedIndex = _isTappable(_selectedIndex ?? -1) ? _selectedIndex : null;
          final isInteractive = widget.points.any((point) => point.tooltip != null);
          return TweenAnimationBuilder<double>(
            key: ValueKey(widget.points.length),
            tween: Tween(begin: 0, end: 1),
            duration: VTMotion.data,
            curve: VTMotion.curve,
            builder: (context, progress, _) {
              final chart = CustomPaint(
                size: Size(width, widget.height),
                painter: _LineChartPainter(
                  points: widget.points,
                  progress: progress,
                  lineColor: line,
                  gridColor: colorScheme.onSurface.withValues(alpha: 0.08),
                  labelColor: colorScheme.onSurfaceVariant,
                  surfaceColor: colorScheme.surface,
                  selectedIndex: selectedIndex,
                ),
              );
              return SizedBox(
                height: widget.height,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (isInteractive)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) => _handleTapAt(details.localPosition.dx, geometry),
                        child: chart,
                      )
                    else
                      chart,
                    if (selectedIndex != null)
                      CustomSingleChildLayout(
                        delegate: VTChartTooltipLayout(anchor: geometry.pointOffset(selectedIndex)),
                        child: VTChartTooltip(label: widget.points[selectedIndex].tooltip!),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LineChartGeometry {
  _LineChartGeometry({required this.points, required this.size});

  final List<VTLineChartPoint> points;
  final Size size;

  static const double yLabelWidth = 44;
  static const double xLabelGutter = 20;
  static const double valuePadFactor = 0.12;

  double get plotWidth => size.width - yLabelWidth;
  double get plotHeight => size.height - xLabelGutter;

  ({double min, double max}) get bounds {
    final values = [for (final point in points) point.value];
    final rawMin = values.reduce(math.min);
    final rawMax = values.reduce(math.max);
    final span = rawMax - rawMin;
    final pad = span == 0 ? math.max(rawMax.abs() * valuePadFactor, 1) : span * valuePadFactor;
    return (min: rawMin - pad, max: rawMax + pad);
  }

  double xFor(int index) => points.length == 1 ? plotWidth / 2 : plotWidth * index / (points.length - 1);

  double yFor(double value) {
    final range = bounds.max - bounds.min;
    return plotHeight * (1 - (value - bounds.min) / range);
  }

  Offset pointOffset(int index) => Offset(xFor(index), yFor(points[index].value));

  int nearestIndex(double dx) {
    var nearest = 0;
    var nearestDistance = double.infinity;
    for (final index in Iterable<int>.generate(points.length)) {
      final distance = (xFor(index) - dx).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = index;
      }
    }
    return nearest;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.progress,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.surfaceColor,
    required this.selectedIndex,
  });

  final List<VTLineChartPoint> points;
  final double progress;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final Color surfaceColor;
  final int? selectedIndex;

  static const double _dotRadius = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }
    final geometry = _LineChartGeometry(points: points, size: size);
    final plotWidth = geometry.plotWidth;
    final plotHeight = geometry.plotHeight;
    if (plotWidth <= 0 || plotHeight <= 0) {
      return;
    }

    final bounds = geometry.bounds;

    _paintGridAndYLabels(canvas, plotWidth: plotWidth, plotHeight: plotHeight, minValue: bounds.min, maxValue: bounds.max);

    final offsets = [for (final index in Iterable<int>.generate(points.length)) geometry.pointOffset(index)];

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, plotWidth * progress + 0.5, size.height));
    _paintArea(canvas, offsets, plotHeight: plotHeight);
    _paintLine(canvas, offsets);
    for (final offset in offsets) {
      canvas.drawCircle(offset, _dotRadius, Paint()..color = lineColor);
    }
    canvas.restore();

    if (selectedIndex != null && selectedIndex! < offsets.length) {
      _paintSelection(canvas, offsets[selectedIndex!], plotHeight: plotHeight);
    }

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

  void _paintSelection(Canvas canvas, Offset offset, {required double plotHeight}) {
    final guide = Paint()
      ..color = lineColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (var y = 0.0; y < plotHeight; y += 6) {
      canvas.drawLine(Offset(offset.dx, y), Offset(offset.dx, math.min(y + 3, plotHeight)), guide);
    }
    canvas
      ..drawCircle(offset, _dotRadius + 3, Paint()..color = surfaceColor)
      ..drawCircle(offset, _dotRadius + 1.5, Paint()..color = lineColor);
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
    )..layout(maxWidth: width ?? _LineChartGeometry.yLabelWidth);
    final dx = align == TextAlign.right ? offset.dx - painter.width : offset.dx;
    painter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.selectedIndex != selectedIndex;
}
