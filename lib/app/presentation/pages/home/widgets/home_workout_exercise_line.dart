import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class HomeWorkoutExerciseLine extends StatelessWidget {
  const HomeWorkoutExerciseLine({required this.workoutExercise, super.key});

  final WorkoutExercise workoutExercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Icon(Icons.radio_button_unchecked, size: 18, color: colorScheme.onSurfaceVariant),
        const VTGap.s(),
        Expanded(
          child: Text(
            workoutExercise.exercise.nameFor(l10n.localeName),
            style: VTTextStyles.body(context),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        if (workoutExercise.sets.isNotEmpty) ...[
          const VTGap.s(),
          Text(
            l10n.homeWorkoutExerciseSets(workoutExercise.sets.length),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant, fontWeight: .w600),
          ),
        ],
      ],
    );
  }
}
