import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_region_volume.dart';
import 'package:vitta/app/presentation/pages/workout_history/widgets/muscle_region_split_row.dart';

class MuscleRegionSplitCard extends StatelessWidget {
  const MuscleRegionSplitCard({required this.days, required this.workoutsByDate, super.key});

  final List<DateTime> days;
  final Map<DateTime, DailyWorkout> workoutsByDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final split = WorkoutRegionVolume.fromWorkouts([
      for (final day in days)
        if (workoutsByDate[day] case final workout?) ...workout.workouts,
    ]);
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.workoutMuscleSplitTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.m(),
          if (!split.hasData)
            Text(l10n.workoutMuscleSplitEmptyMessage, style: VTTextStyles.caption(context))
          else ...[
            VTDistributionBar(
              segments: [
                for (final region in split.presentRegions) VTBarChartSegment(value: split.volumeOf(region), color: region.color),
              ],
            ),
            const VTGap.m(),
            for (final region in split.presentRegions) ...[
              MuscleRegionSplitRow(region: region, share: split.shareOf(region)),
              const VTGap.s(),
            ],
          ],
        ],
      ),
    );
  }
}
