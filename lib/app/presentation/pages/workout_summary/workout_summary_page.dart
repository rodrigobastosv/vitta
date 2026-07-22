import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/workout_duration_format.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_metric.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/session_progress_card.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/workout_summary_exercise_row.dart';
import 'package:vitta/app/presentation/pages/workout_summary/widgets/workout_summary_hero.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';

class WorkoutSummaryPage extends StatelessWidget {
  const WorkoutSummaryPage({required this.extra, super.key});

  final WorkoutSummaryExtra extra;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final regions = {for (final workout in extra.workouts) ...workout.regions}.toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(VTSpacing.m),
        children: [
          VTCelebration(
            trigger: true,
            child: VTAppearEffect(
              child: WorkoutSummaryHero(
                date: extra.date,
                estimatedCalories: extra.estimatedCalories(bodyWeightKg: extra.latestBodyWeightKg).round(),
                isBodyWeightKnown: extra.isBodyWeightKnown,
              ),
            ),
          ),
          const VTGap.m(),
          VTAppearEffect(index: 1, child: VTCard(child: Column(children: _metrics(context)))),
          if (regions.isNotEmpty) ...[
            const VTGap.m(),
            VTAppearEffect(
              index: 2,
              child: Wrap(
                spacing: VTSpacing.s,
                runSpacing: VTSpacing.s,
                children: [for (final region in regions) VTBadge(label: region.getLabel(l10n), color: region.color)],
              ),
            ),
          ],
          const VTGap.m(),
          VTAppearEffect(index: 3, child: SessionProgressCard(progress: extra.progress, unitSystem: extra.unitSystem)),
          const VTGap.m(),
          VTAppearEffect(
            index: 4,
            child: VTCard(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(l10n.workoutSummaryExercisesTitle, style: VTTextStyles.title(context)),
                  const VTGap.m(),
                  for (final (index, exercise) in extra.exercises.indexed) ...[
                    if (index > 0) const VTGap.m(),
                    WorkoutSummaryExerciseRow(workoutExercise: exercise, unitSystem: extra.unitSystem),
                  ],
                ],
              ),
            ),
          ),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.workoutSummaryDoneAction, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  List<Widget> _metrics(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final hasStrength = extra.sets.any((set) => !set.isCardio);
    final metrics = <Widget>[
      if (hasStrength)
        WorkoutMetric(icon: Icons.fitness_center, label: l10n.workoutVolumeLabel, value: _formatLoad(extra.volumeKg), color: colorScheme.primary),
      WorkoutMetric(icon: Icons.layers_outlined, label: l10n.workoutSetsLabel, value: '${extra.totalSets}'),
      if (hasStrength) WorkoutMetric(icon: Icons.repeat_rounded, label: l10n.workoutTotalRepsLabel, value: '${extra.totalReps}'),
      if (extra.hasCardio)
        WorkoutMetric(icon: Icons.timer_outlined, label: l10n.workoutTimeLabel, value: formatWorkoutDuration(l10n, extra.totalDurationSeconds)),
      if (extra.totalDistanceMeters > 0)
        WorkoutMetric(
          icon: Icons.straighten,
          label: l10n.workoutDistanceMetricLabel,
          value: formatWorkoutDistance(extra.unitSystem, extra.totalDistanceMeters),
        ),
    ];
    return [
      for (final (index, metric) in metrics.indexed) ...[if (index > 0) const VTGap.m(), metric],
    ];
  }

  String _formatLoad(double kilograms) {
    final value = extra.unitSystem.kilogramsToDisplayLoad(kilograms);
    return '${value.round()} ${extra.unitSystem.loadUnitLabel}';
  }
}
