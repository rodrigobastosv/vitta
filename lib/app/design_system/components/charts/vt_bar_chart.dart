import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';

class VTBarChart extends StatelessWidget {
  const VTBarChart({required this.bars, this.referenceValue, this.referenceColor, this.emptySlotColor, this.height = 140, super.key});

  final List<VTBarChartBar> bars;
  final double? referenceValue;
  final Color? referenceColor;
  final Color? emptySlotColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, growth, _) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarChartPainter(
            bars: bars,
            growth: growth,
            referenceValue: referenceValue,
            referenceColor: referenceColor ?? colorScheme.onSurfaceVariant,
            emptySlotColor: emptySlotColor ?? colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.bars,
    required this.growth,
    required this.referenceValue,
    required this.referenceColor,
    required this.emptySlotColor,
  });

  final List<VTBarChartBar> bars;
  final double growth;
  final double? referenceValue;
  final Color referenceColor;
  final Color emptySlotColor;

  static const double _slotGapFactor = 0.28;
  static const double _maxBarWidth = 28;
  static const double _dashWidth = 4;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) {
      return;
    }
    final highestValue = _highestValue();
    if (highestValue <= 0) {
      return;
    }

    final slotWidth = size.width / bars.length;
    final barWidth = math.min(slotWidth * (1 - _slotGapFactor), _maxBarWidth);
    final radius = Radius.circular(math.min(barWidth / 2, 4));

    for (final (index, bar) in bars.indexed) {
      final left = slotWidth * index + (slotWidth - barWidth) / 2;
      if (bar.segments.isEmpty) {
        _paintEmptySlot(canvas, left: left, width: barWidth, size: size, radius: radius);
        continue;
      }
      _paintBar(canvas, bar: bar, left: left, width: barWidth, size: size, highestValue: highestValue, radius: radius);
    }

    _paintReferenceLine(canvas, size: size, highestValue: highestValue);
  }

  double _highestValue() {
    final highestBar = bars.fold<double>(0, (highest, bar) => math.max(highest, bar.total));
    return math.max(highestBar, referenceValue ?? 0);
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
    final barRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(left, size.height - barHeight, width, barHeight),
      topLeft: radius,
      topRight: radius,
    );

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
      oldDelegate.emptySlotColor != emptySlotColor;
}
