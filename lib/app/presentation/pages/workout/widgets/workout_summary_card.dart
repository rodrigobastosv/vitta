import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/workout_duration_format.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_metric.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({required this.state, required this.unitSystem, super.key});

  final WorkoutState state;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final regions = {for (final workout in state.workouts) ...workout.regions}.toList();
    final completed = state.completedExercises;
    final total = state.exercises.length;
    final accent = state.isFinished ? VTColors.success : colorScheme.primary;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTMacroRing(
                value: total == 0 ? 0 : completed / total,
                color: accent,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text('$completed/$total', style: VTTextStyles.headline(context)),
                    Text(l10n.workoutExercisesLabel, style: VTTextStyles.caption(context)),
                    const VTGap.xs(),
                    Text(
                      l10n.workoutExercisesLeft(total - completed),
                      style: VTTextStyles.overline(context).copyWith(color: accent, fontWeight: .w700),
                    ),
                  ],
                ),
              ),
              const VTGap.l(),
              Expanded(child: Column(children: _metrics(context, l10n, colorScheme))),
            ],
          ),
          if (regions.isNotEmpty) ...[
            const VTGap.m(),
            const Divider(height: 1),
            const VTGap.m(),
            Wrap(
              spacing: VTSpacing.s,
              runSpacing: VTSpacing.s,
              children: [for (final region in regions) VTBadge(label: region.getLabel(l10n), color: region.color)],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _metrics(BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    final hasStrength = state.sets.any((set) => !set.isCardio);
    final metrics = <Widget>[
      if (hasStrength) WorkoutMetric(icon: Icons.fitness_center, label: l10n.workoutVolumeLabel, value: _formatLoad(state.volumeKg), color: colorScheme.primary),
      WorkoutMetric(icon: Icons.layers_outlined, label: l10n.workoutSetsLabel, value: '${state.totalSets}'),
      if (hasStrength) WorkoutMetric(icon: Icons.repeat_rounded, label: l10n.workoutTotalRepsLabel, value: '${state.totalReps}'),
      if (state.hasCardio)
        WorkoutMetric(
          icon: Icons.timer_outlined,
          label: l10n.workoutTimeLabel,
          value: formatWorkoutDuration(l10n, state.totalDurationSeconds),
          color: hasStrength ? null : colorScheme.primary,
        ),
      if (state.totalDistanceMeters > 0)
        WorkoutMetric(icon: Icons.straighten, label: l10n.workoutDistanceMetricLabel, value: formatWorkoutDistance(unitSystem, state.totalDistanceMeters)),
    ];
    return [
      for (final (index, metric) in metrics.indexed) ...[if (index > 0) const VTGap.m(), metric],
    ];
  }

  String _formatLoad(double kilograms) {
    final value = unitSystem.kilogramsToDisplayLoad(kilograms);
    return '${value.round()} ${unitSystem.loadUnitLabel}';
  }
}
