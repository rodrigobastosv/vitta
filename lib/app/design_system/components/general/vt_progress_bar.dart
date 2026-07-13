import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTProgressBar extends StatelessWidget {
  const VTProgressBar({required this.value, this.minHeight = 8, this.color, this.trackColor, super.key});

  final double value;
  final double minHeight;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value.clamp(0, 1).toDouble()),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOutCubic,
    builder: (context, animatedValue, child) => ClipRRect(
      borderRadius: VTRadius.borderRadiusS,
      child: LinearProgressIndicator(
        value: animatedValue,
        minHeight: minHeight,
        color: color,
        backgroundColor: trackColor ?? color?.withValues(alpha: 0.16),
      ),
    ),
  );
}
