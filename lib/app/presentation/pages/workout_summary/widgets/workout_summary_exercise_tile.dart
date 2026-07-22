import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_sets_summary.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_thumbnail.dart';

class WorkoutSummaryExerciseTile extends StatelessWidget {
  const WorkoutSummaryExerciseTile({required this.workoutExercise, required this.unitSystem, super.key});

  final WorkoutExercise workoutExercise;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final region = workoutExercise.exercise.primaryMuscles.firstOrNull?.region;
    final summary = WorkoutSetsSummary.format(sets: workoutExercise.sets, unitSystem: unitSystem, l10n: l10n);
    return VTCard(
      child: Row(
        children: [
          // Never greyscale here: the exercise thumbnail is drained on the day
          // view to say "finished", but on a summary every exercise is finished,
          // so draining them all would only make the recap look switched off.
          WorkoutExerciseThumbnail(imageUrl: workoutExercise.exercise.imageUrl, isCompleted: false),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(workoutExercise.exercise.nameFor(l10n.localeName), style: VTTextStyles.bodyStrong(context)),
                if (summary != null) ...[const VTGap.xs(), Text(summary, style: VTTextStyles.caption(context))],
              ],
            ),
          ),
          if (region != null) ...[const SizedBox(width: VTSpacing.s), VTBadge(label: region.getLabel(l10n), color: region.color)],
        ],
      ),
    );
  }
}
