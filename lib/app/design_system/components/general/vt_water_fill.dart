import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';

class VTWaterFill extends StatefulWidget {
  const VTWaterFill({required this.value, required this.color, this.width = 92, this.height = 150, this.semanticLabel, super.key});

  final double value;
  final Color color;
  final double width;
  final double height;
  final String? semanticLabel;

  @override
  State<VTWaterFill> createState() => _VTWaterFillState();
}

class _VTWaterFillState extends State<VTWaterFill> with SingleTickerProviderStateMixin {
  late final AnimationController _waves = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

  @override
  void dispose() {
    _waves.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VTSemanticSummary(
    label: widget.semanticLabel,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.value.clamp(0, 1).toDouble()),
      duration: VTMotion.data,
      curve: VTMotion.curve,
      builder: (context, level, _) => AnimatedBuilder(
        animation: _waves,
        builder: (context, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _WaterFillPainter(level: level, phase: MediaQuery.disableAnimationsOf(context) ? 0 : _waves.value, color: widget.color),
        ),
      ),
    ),
  );
}

class _WaterFillPainter extends CustomPainter {
  _WaterFillPainter({required this.level, required this.phase, required this.color});

  final double level;
  final double phase;
  final Color color;

  static const double _cornerRadius = 24;
  static const double _amplitude = 5;
  static const double _waves = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final glass = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(_cornerRadius));

    canvas
      ..save()
      ..clipRRect(glass)
      ..drawRect(Offset.zero & size, Paint()..color = color.withValues(alpha: 0.10));

    if (level > 0) {
      final waterTop = size.height * (1 - level);
      _drawWave(canvas, size, baseY: waterTop, phase: phase + 0.5, amplitude: -_amplitude, color: color.withValues(alpha: 0.35));
      _drawWave(canvas, size, baseY: waterTop, phase: phase, amplitude: _amplitude, color: color.withValues(alpha: 0.85));
    }
    canvas.restore();

    canvas.drawRRect(
      glass,
      Paint()
        ..style = .stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.35),
    );
  }

  void _drawWave(Canvas canvas, Size size, {required double baseY, required double phase, required double amplitude, required Color color}) {
    final path = Path()..moveTo(0, baseY);
    for (var x = 0.0; x <= size.width; x += 2) {
      final y = baseY + amplitude * math.sin((x / size.width * _waves + phase) * 2 * math.pi);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WaterFillPainter oldDelegate) => oldDelegate.level != level || oldDelegate.phase != phase || oldDelegate.color != color;
}
