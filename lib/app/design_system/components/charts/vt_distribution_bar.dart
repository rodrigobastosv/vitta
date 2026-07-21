import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/general/vt_semantic_summary.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

class VTDistributionBar extends StatelessWidget {
  const VTDistributionBar({required this.segments, this.height = 10, this.semanticLabel, super.key});

  final List<VTBarChartSegment> segments;
  final double height;
  final String? semanticLabel;

  static const int _flexPrecision = 1000;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, segment) => sum + segment.value);
    if (total <= 0) {
      return SizedBox(height: height);
    }
    return VTSemanticSummary(
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: VTRadius.borderRadiusFull,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (final segment in segments)
                if (segment.value > 0)
                  Expanded(
                    flex: (segment.value / total * _flexPrecision).round(),
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: segment.color),
                      duration: VTMotion.entrance,
                      builder: (context, color, _) => ColoredBox(color: color ?? Colors.transparent),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
