import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';

class ExerciseProgressionChartCard extends StatelessWidget {
  const ExerciseProgressionChartCard({
    required this.title,
    required this.points,
    required this.valueOf,
    required this.color,
    required this.unitSystem,
    super.key,
  });

  final String title;
  final List<ExerciseProgressionPoint> points;
  final double Function(ExerciseProgressionPoint point) valueOf;
  final Color color;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = points.isEmpty ? 0.0 : valueOf(points.last);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: VTTextStyles.bodyStrong(context))),
              VTBadge(label: _formatLoad(latest), color: color),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.workoutProgressionSessionCount(points.length), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          VTBarChart(
            bars: [
              for (final point in points)
                VTBarChartBar(
                  segments: [VTBarChartSegment(value: unitSystem.kilogramsToDisplayLoad(valueOf(point)), color: color)],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLoad(double kilograms) {
    final value = unitSystem.kilogramsToDisplayLoad(kilograms);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
