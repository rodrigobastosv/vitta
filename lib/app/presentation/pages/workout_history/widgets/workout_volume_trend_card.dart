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
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';

class WorkoutVolumeTrendCard extends StatelessWidget {
  const WorkoutVolumeTrendCard({required this.days, required this.workoutsByDate, required this.unitSystem, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyWorkout> workoutsByDate;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final trainedDays = [for (final day in days) if (workoutsByDate[day] case final workout? when workout.hasData) workout];
    final sessionCount = trainedDays.length;
    final totalVolumeKg = trainedDays.fold<double>(0, (sum, workout) => sum + workout.volumeKg);
    final totalSets = trainedDays.fold<int>(0, (sum, workout) => sum + workout.totalSets);
    final averageVolumeKg = sessionCount == 0 ? 0.0 : totalVolumeKg / sessionCount;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.workoutVolumeTrendTitle, style: VTTextStyles.bodyStrong(context))),
              if (sessionCount > 0) VTBadge(label: l10n.workoutVolumeAverageLabel(_formatVolume(averageVolumeKg)), color: colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.workoutHistoryVolumeSummary(sessionCount, totalSets), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          if (sessionCount == 0)
            Text(l10n.dietTrendEmptyMessage, style: VTTextStyles.caption(context))
          else
            VTBarChart(
              bars: [
                for (final day in days)
                  if (workoutsByDate[day] case final workout? when workout.hasData)
                    VTBarChartBar(
                      segments: [VTBarChartSegment(value: unitSystem.kilogramsToDisplayLoad(workout.volumeKg), color: colorScheme.primary)],
                    )
                  else
                    const VTBarChartBar.empty(),
              ],
            ),
        ],
      ),
    );
  }

  String _formatVolume(double kilograms) => '${unitSystem.kilogramsToDisplayLoad(kilograms).round()} ${unitSystem.loadUnitLabel}';
}
