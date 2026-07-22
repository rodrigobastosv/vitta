import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';

class WorkoutCardioTrendCard extends StatelessWidget {
  const WorkoutCardioTrendCard({required this.days, required this.workoutsByDate, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyWorkout> workoutsByDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final cardioDays = [
      for (final day in days)
        if (workoutsByDate[day] case final workout? when workout.hasCardio) workout,
    ];
    final cardioDayCount = cardioDays.length;
    final totalMinutes = cardioDays.fold<int>(0, (sum, workout) => sum + workout.totalDurationSeconds ~/ 60);
    final averageMinutes = cardioDayCount == 0 ? 0 : (totalMinutes / cardioDayCount).round();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.workoutCardioTrendTitle, style: VTTextStyles.bodyStrong(context))),
              if (cardioDayCount > 0) VTBadge(label: l10n.workoutCardioTrendAverage(averageMinutes), color: colorScheme.tertiary),
            ],
          ),
          const VTGap.m(),
          if (cardioDayCount == 0)
            Text(l10n.workoutCardioTrendEmptyMessage, style: VTTextStyles.caption(context))
          else
            VTBarChart(
              bars: [
                for (final day in days)
                  if (workoutsByDate[day] case final workout? when workout.hasCardio)
                    VTBarChartBar(
                      segments: [VTBarChartSegment(value: workout.totalDurationSeconds / 60, color: colorScheme.tertiary)],
                    )
                  else
                    const VTBarChartBar.empty(),
              ],
            ),
        ],
      ),
    );
  }
}
