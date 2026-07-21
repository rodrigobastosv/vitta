import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTProgressBar extends StatelessWidget {
  const VTProgressBar({required this.value, this.minHeight = 8, this.color, this.trackColor, this.semanticLabel, super.key});

  final double value;
  final double minHeight;
  final Color? color;
  final Color? trackColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => VTSemanticSummary(
    label: semanticLabel,
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1).toDouble()),
      duration: VTMotion.data,
      curve: VTMotion.curve,
      builder: (context, animatedValue, child) => ClipRRect(
        borderRadius: VTRadius.borderRadiusS,
        child: LinearProgressIndicator(value: animatedValue, minHeight: minHeight, color: color, backgroundColor: trackColor ?? color?.withValues(alpha: 0.16)),
      ),
    ),
  );
}
