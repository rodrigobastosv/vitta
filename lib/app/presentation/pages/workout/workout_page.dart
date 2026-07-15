import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/exercise_detail_extra.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/log_set_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/next_routine_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_date_selector.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        WorkoutShowLoading() => context.showLoading(),
        WorkoutHideLoading() => context.hideLoading(),
        WorkoutError(:final message, :final date) => context.showErrorDialog(
          message: message,
          onRetry: () => context.read<WorkoutCubit>().goToDate(date),
        ),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.workoutFeatureTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: l10n.workoutRoutinesTooltip,
              onPressed: () async {
                await context.pushRoute(.routines);
                // Routines may have been added, reordered or deleted, which
                // changes what the cycle suggests next.
                if (context.mounted) {
                  await cubit.loadDate(cubit.state.date);
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addExercise(context, cubit),
          icon: const Icon(Icons.add),
          label: Text(l10n.workoutAddExercise),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.xxl * 2),
          children: [
            WorkoutDateSelector(
              date: state.date,
              canGoToNextDay: state.date.isBefore(_today()),
              onPreviousDay: () => cubit.goToDate(state.date.subtract(const Duration(days: 1))),
              onNextDay: () => cubit.goToDate(state.date.add(const Duration(days: 1))),
            ),
            const VTGap.m(),
            if (state.isEmpty) ...[
              // Starting a routine is offered only on today, and only on a day
              // with nothing logged: you can't begin a session in the past, and
              // once the workout exists, starting it again would duplicate every
              // exercise. Past days stay editable - fixing a set you forgot to
              // log is a different thing from starting the workout.
              if (state.isToday)
                if (state.cycle.next case final next?) ...[
                  VTAppearEffect(
                    child: NextRoutineCard(routine: next, onStart: () => cubit.startRoutine(next)),
                  ),
                  const VTGap.m(),
                ],
              VTEmptyState(icon: Icons.fitness_center_outlined, title: l10n.workoutEmptyTitle, message: l10n.workoutEmptyMessage),
            ] else ...[
              VTAppearEffect(
                child: WorkoutSummaryCard(state: state, unitSystem: cubit.unitSystem),
              ),
              const VTGap.m(),
              for (final workout in state.workouts)
                for (final (index, workoutExercise) in workout.exercises.indexed) ...[
                  VTAppearEffect(
                    delay: Duration(milliseconds: 60 * (index + 1)),
                    child: WorkoutExerciseCard(
                      workoutExercise: workoutExercise,
                      unitSystem: cubit.unitSystem,
                      onTap: () => context.pushRoute(.exerciseDetail, extra: ExerciseDetailExtra(exercise: workoutExercise.exercise)),
                      onRemove: () => cubit.removeExercise(workoutExerciseId: workoutExercise.id),
                      onAddSet: () => showLogSetSheet(
                        context: context,
                        unitSystem: cubit.unitSystem,
                        onSubmit: ({required reps, required weightKg}) =>
                            cubit.logSet(workoutExerciseId: workoutExercise.id, reps: reps, weightKg: weightKg),
                      ),
                      onEditSet: (set) => showLogSetSheet(
                        context: context,
                        unitSystem: cubit.unitSystem,
                        set: set,
                        onSubmit: ({required reps, required weightKg}) => cubit.updateSet(setId: set.id, reps: reps, weightKg: weightKg),
                      ),
                      onDeleteSet: (set) => cubit.deleteSet(setId: set.id),
                    ),
                  ),
                  const VTGap.m(),
                ],
            ],
          ],
        ),
      ),
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _addExercise(BuildContext context, WorkoutCubit cubit) async {
    final exercise = await context.pushRoute<Exercise>(.exerciseSearch);
    if (exercise != null) {
      await cubit.addExercise(exercise);
    }
  }
}
