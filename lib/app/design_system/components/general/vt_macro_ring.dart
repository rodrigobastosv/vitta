import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

class VTMacroRing extends StatelessWidget {
  const VTMacroRing({
    required this.value,
    required this.color,
    this.size = 132,
    this.strokeWidth = 12,
    this.trackColor,
    this.child,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => switch (semanticLabel) {
    final semanticLabel? => VTSemanticSummary(label: semanticLabel, child: _ring()),
    null => MergeSemantics(child: _ring()),
  };

  Widget _ring() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.clamp(0, 1).toDouble()),
    duration: VTMotion.data,
    curve: VTMotion.curve,
    builder: (context, animatedValue, _) => SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(value: animatedValue, color: color, trackColor: trackColor ?? color.withValues(alpha: 0.16), strokeWidth: strokeWidth),
        child: Center(child: child),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.trackColor, required this.strokeWidth});

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = .round
      ..color = trackColor;
    canvas.drawArc(rect, _startAngle, 2 * math.pi, false, track);

    if (value <= 0) {
      return;
    }
    final progress = Paint()
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = .round
      ..color = color;
    canvas.drawArc(rect, _startAngle, 2 * math.pi * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color || oldDelegate.trackColor != trackColor || oldDelegate.strokeWidth != strokeWidth;
}
