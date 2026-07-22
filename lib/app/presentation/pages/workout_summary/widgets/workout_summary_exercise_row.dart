import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_sets_summary.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_thumbnail.dart';

class WorkoutSummaryExerciseRow extends StatelessWidget {
  const WorkoutSummaryExerciseRow({required this.workoutExercise, required this.unitSystem, super.key});

  final WorkoutExercise workoutExercise;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final summary = WorkoutSetsSummary.format(sets: workoutExercise.sets, unitSystem: unitSystem, l10n: l10n);
    return Row(
      children: [
        WorkoutExerciseThumbnail(imageUrl: workoutExercise.exercise.imageUrl, isCompleted: false),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                workoutExercise.exercise.nameFor(l10n.localeName),
                style: VTTextStyles.bodyStrong(context),
                maxLines: 1,
                overflow: .ellipsis,
              ),
              if (summary != null) ...[
                const VTGap.xs(),
                Text(summary, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
