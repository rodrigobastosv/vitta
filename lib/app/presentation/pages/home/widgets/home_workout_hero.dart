import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_workout_exercise_line.dart';

// A workout is either waiting to be started - in which case what matters is
// which routine is up next - or already under way, where what matters is what
// is still left to do.
class HomeWorkoutHero extends StatelessWidget {
  const HomeWorkoutHero({
    required this.completedExercises,
    required this.totalExercises,
    required this.remainingExercises,
    required this.nextRoutine,
    required this.onTap,
    super.key,
  });

  static const _visibleExercises = 3;

  final int completedExercises;
  final int totalExercises;
  final List<WorkoutExercise> remainingExercises;
  final Routine? nextRoutine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final hasWorkout = totalExercises > 0;
    final isFinished = hasWorkout && completedExercises == totalExercises;
    final visible = remainingExercises.take(_visibleExercises).toList();
    final remaining = remainingExercises.length - visible.length;
    return VTCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTMacroRing(
                value: hasWorkout ? completedExercises / totalExercises : 0,
                color: isFinished ? VTColors.success : colorScheme.primary,
                size: 104,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(hasWorkout ? '$completedExercises/$totalExercises' : '—', style: VTTextStyles.headline(context)),
                    Text(l10n.workoutFeatureTitle, style: VTTextStyles.overline(context)),
                  ],
                ),
              ),
              const VTGap.l(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(l10n.homeWorkoutHeroTitle, style: VTTextStyles.title(context)),
                    const VTGap.xs(),
                    Text(
                      switch ((hasWorkout, isFinished)) {
                        (false, _) => l10n.homeWorkoutNotStarted,
                        (_, true) => l10n.homeWorkoutFinished,
                        _ => l10n.homeWorkoutRemaining(remainingExercises.length),
                      },
                      style: VTTextStyles.caption(context).copyWith(color: isFinished ? VTColors.success : colorScheme.onSurfaceVariant),
                    ),
                    if (hasWorkout ? null : nextRoutine case final routine?) ...[
                      const VTGap.xs(),
                      Text(
                        l10n.homeWorkoutNextUp(routine.name),
                        style: VTTextStyles.caption(context).copyWith(color: colorScheme.primary, fontWeight: .w700),
                        maxLines: 2,
                        overflow: .ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          for (final workoutExercise in visible) ...[const VTGap.s(), HomeWorkoutExerciseLine(workoutExercise: workoutExercise)],
          if (remaining > 0) ...[
            const VTGap.s(),
            Text(l10n.homeRemindersMore(remaining), style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
