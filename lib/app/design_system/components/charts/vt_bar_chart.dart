import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_chart_tooltip.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTBarChart extends StatefulWidget {
  const VTBarChart({required this.bars, this.referenceValue, this.referenceColor, this.emptySlotColor, this.height = 140, this.semanticLabel, super.key});

  final List<VTBarChartBar> bars;
  final double? referenceValue;
  final Color? referenceColor;
  final Color? emptySlotColor;
  final double height;
  final String? semanticLabel;

  @override
  State<VTBarChart> createState() => _VTBarChartState();
}

class _VTBarChartState extends State<VTBarChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(VTBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bars != widget.bars) {
      _selectedIndex = null;
    }
  }

  bool _isTappable(int index) => index >= 0 && index < widget.bars.length && widget.bars[index].tooltip != null && widget.bars[index].segments.isNotEmpty;

  void _handleTapAt(double dx, double width) {
    if (widget.bars.isEmpty || width <= 0) {
      return;
    }
    final slotWidth = width / widget.bars.length;
    final index = (dx / slotWidth).floor().clamp(0, widget.bars.length - 1);
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
    return VTSemanticSummary(
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final geometry = _BarChartGeometry(bars: widget.bars, size: Size(width, widget.height), referenceValue: widget.referenceValue);
          final selectedIndex = _isTappable(_selectedIndex ?? -1) ? _selectedIndex : null;
          final isInteractive = widget.bars.any((bar) => bar.tooltip != null);
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: VTMotion.data,
            curve: VTMotion.curve,
            builder: (context, growth, _) {
              final chart = CustomPaint(
                size: Size(width, widget.height),
                painter: _BarChartPainter(
                  bars: widget.bars,
                  growth: growth,
                  referenceValue: widget.referenceValue,
                  referenceColor: widget.referenceColor ?? colorScheme.onSurfaceVariant,
                  emptySlotColor: widget.emptySlotColor ?? colorScheme.onSurface.withValues(alpha: 0.06),
                  selectedIndex: selectedIndex,
                  highlightColor: colorScheme.onSurface.withValues(alpha: 0.07),
                  baselineColor: colorScheme.onSurface.withValues(alpha: 0.08),
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
                        onTapDown: (details) => _handleTapAt(details.localPosition.dx, width),
                        child: chart,
                      )
                    else
                      chart,
                    if (selectedIndex != null)
                      CustomSingleChildLayout(
                        delegate: VTChartTooltipLayout(anchor: geometry.tooltipAnchor(selectedIndex)),
                        child: VTChartTooltip(label: widget.bars[selectedIndex].tooltip!),
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

class _BarChartGeometry {
  _BarChartGeometry({required this.bars, required this.size, required this.referenceValue});

  final List<VTBarChartBar> bars;
  final Size size;
  final double? referenceValue;

  static const double slotGapFactor = 0.28;
  static const double maxBarWidth = 28;

  double get highestValue {
    final highestBar = bars.fold<double>(0, (highest, bar) => math.max(highest, bar.total));
    return math.max(highestBar, referenceValue ?? 0);
  }

  double get slotWidth => bars.isEmpty ? 0 : size.width / bars.length;

  double get barWidth => math.min(slotWidth * (1 - slotGapFactor), maxBarWidth);

  double slotCenterX(int index) => slotWidth * index + slotWidth / 2;

  double barTopY(int index) {
    final highest = highestValue;
    if (highest <= 0) {
      return size.height;
    }
    return size.height - size.height * (bars[index].total / highest);
  }

  Offset tooltipAnchor(int index) => Offset(slotCenterX(index), barTopY(index));
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.bars,
    required this.growth,
    required this.referenceValue,
    required this.referenceColor,
    required this.emptySlotColor,
    required this.selectedIndex,
    required this.highlightColor,
    required this.baselineColor,
  });

  final List<VTBarChartBar> bars;
  final double growth;
  final double? referenceValue;
  final Color referenceColor;
  final Color emptySlotColor;
  final int? selectedIndex;
  final Color highlightColor;
  final Color baselineColor;

  static const double _dashWidth = 4;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }
    final geometry = _BarChartGeometry(bars: bars, size: size, referenceValue: referenceValue);
    final highestValue = geometry.highestValue;
    if (highestValue <= 0) {
      return;
    }

    final barWidth = geometry.barWidth;
    final radius = Radius.circular(math.min(barWidth / 2, 4));

    final baseline = Paint()
      ..color = baselineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), baseline);

    if (selectedIndex != null) {
      _paintSelectionBand(canvas, geometry: geometry, index: selectedIndex!, size: size);
    }

    for (final (index, bar) in bars.indexed) {
      final left = geometry.slotWidth * index + (geometry.slotWidth - barWidth) / 2;
      if (bar.segments.isEmpty) {
        _paintEmptySlot(canvas, left: left, width: barWidth, size: size, radius: radius);
        continue;
      }
      _paintBar(canvas, bar: bar, left: left, width: barWidth, size: size, highestValue: highestValue, radius: radius);
    }

    _paintReferenceLine(canvas, size: size, highestValue: highestValue);
  }

  void _paintSelectionBand(Canvas canvas, {required _BarChartGeometry geometry, required int index, required Size size}) {
    final bandWidth = math.min(geometry.slotWidth, geometry.barWidth + VTSpacing.s * 2);
    final left = geometry.slotCenterX(index) - bandWidth / 2;
    final band = RRect.fromRectAndCorners(
      Rect.fromLTWH(left, 0, bandWidth, size.height),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(band, Paint()..color = highlightColor);
  }

  void _paintEmptySlot(Canvas canvas, {required double left, required double width, required Size size, required Radius radius}) {
    final track = RRect.fromRectAndCorners(Rect.fromLTWH(left, size.height - 3, width, 3), topLeft: radius, topRight: radius);
    canvas.drawRRect(track, Paint()..color = emptySlotColor);
  }

  void _paintBar(
    Canvas canvas, {
    required VTBarChartBar bar,
    required double left,
    required double width,
    required Size size,
    required double highestValue,
    required Radius radius,
  }) {
    final barHeight = size.height * (bar.total / highestValue) * growth;
    final barRect = RRect.fromRectAndCorners(Rect.fromLTWH(left, size.height - barHeight, width, barHeight), topLeft: radius, topRight: radius);

    canvas
      ..save()
      ..clipRRect(barRect);
    var bottom = size.height;
    for (final segment in bar.segments) {
      final segmentHeight = size.height * (segment.value / highestValue) * growth;
      canvas.drawRect(Rect.fromLTWH(left, bottom - segmentHeight, width, segmentHeight), Paint()..color = segment.color);
      bottom -= segmentHeight;
    }
    canvas.restore();
  }

  void _paintReferenceLine(Canvas canvas, {required Size size, required double highestValue}) {
    final reference = referenceValue;
    if (reference == null || reference <= 0) {
      return;
    }
    final y = size.height - size.height * (reference / highestValue);
    final paint = Paint()
      ..color = referenceColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += _dashWidth + _dashGap) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + _dashWidth, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.growth != growth ||
      oldDelegate.bars != bars ||
      oldDelegate.referenceValue != referenceValue ||
      oldDelegate.referenceColor != referenceColor ||
      oldDelegate.emptySlotColor != emptySlotColor ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.baselineColor != baselineColor;
}
