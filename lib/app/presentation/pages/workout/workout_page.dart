import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/components/general/vt_rest_timer.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/equipment.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/log_set_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/next_routine_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/rest_length_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_date_selector.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_exercise_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_finished_card.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_summary_card.dart';
import 'package:vitta/app/presentation/pages/workout/workout_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';
import 'package:vitta/app/presentation/pages/workout_summary/workout_summary_extra.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  // A rest times the gap before the next set of *that* exercise, so finishing it
  // ends the rest rather than leaving it counting down over whatever the user
  // opens next (issue #228) - the same "there is no next set to rest for" rule
  // that already withholds a rest after a cardio effort.
  static Future<void> _setCompleted(
    BuildContext context,
    WorkoutCubit cubit, {
    required WorkoutExercise workoutExercise,
    required bool completed,
  }) async {
    if (completed) {
      context.read<RestTimerCubit>().skip();
    }
    await cubit.setExerciseCompleted(workoutExercise: workoutExercise, completed: completed);
  }

  static Future<void> _showSummary(BuildContext context, WorkoutCubit cubit) => context.pushRoute(
    .workoutSummary,
    extra: WorkoutSummaryExtra(
      date: cubit.state.date,
      workouts: cubit.state.workouts,
      lastSetsByExercise: cubit.state.lastSetsByExercise,
      latestBodyWeightKg: cubit.state.latestBodyWeightKg,
      unitSystem: cubit.unitSystem,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<WorkoutCubit, WorkoutState, WorkoutPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        WorkoutShowLoading() => context.showLoading(),
        WorkoutHideLoading() => context.hideLoading(),
        WorkoutShowIntro() => unawaited(_showIntro(context, context.read<WorkoutCubit>())),
        WorkoutError(:final message, :final date) => context.showErrorToast(message: message, onRetry: () => context.read<WorkoutCubit>().goToDate(date)),
        WorkoutSessionFinished() => unawaited(_showSummary(context, context.read<WorkoutCubit>())),
        WorkoutSetRepeated(:final workoutExercise) => context.read<RestTimerCubit>().start(label: workoutExercise.exercise.nameFor(l10n.localeName)),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.workoutFeatureTitle),
          actions: [
            IconButton(icon: const Icon(Icons.calendar_month), tooltip: l10n.workoutHistoryTitle, onPressed: () => context.pushRoute(.workoutHistory)),
            IconButton(
              icon: const Icon(Icons.query_stats),
              tooltip: l10n.workoutProgressionListTitle,
              onPressed: () => context.pushRoute(.exerciseProgressionList),
            ),
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: l10n.workoutRoutinesTooltip,
              onPressed: () async {
                await context.pushRoute(.routines);
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
        bottomNavigationBar: BlocBuilder<RestTimerCubit, RestTimerState>(
          builder: (context, timer) => timer.isRunning
              ? SafeArea(
                  minimum: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.s),
                  child: VTRestTimer(
                    remaining: timer.remaining,
                    progress: timer.progress,
                    label: timer.label,
                    onExtend: context.read<RestTimerCubit>().extend,
                    onShorten: context.read<RestTimerCubit>().shorten,
                    onSkip: context.read<RestTimerCubit>().skip,
                    onConfigure: () => _configureRest(context),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: VTRefreshable(
          onRefresh: () => cubit.loadDate(state.date),
          isLoaded: state.isLoaded,
          skeleton: const ListSkeleton(headerHeight: 260),
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
              if (state.isToday)
                if (state.cycle.next case final next?) ...[
                  VTAppearEffect(
                    child: NextRoutineCard(routine: next, onStart: () => cubit.startRoutine(next)),
                  ),
                  const VTGap.m(),
                ],
              VTEmptyState(icon: Icons.fitness_center_outlined, title: l10n.workoutEmptyTitle, message: l10n.workoutEmptyMessage),
            ] else ...[
              VTAppearEffect(child: WorkoutSummaryCard(state: state, unitSystem: cubit.unitSystem)),
              const VTGap.m(),
              if (state.isFinished) ...[
                VTAppearEffect(
                  child: WorkoutFinishedCard(
                    estimatedCalories: state.estimatedCalories(bodyWeightKg: state.latestBodyWeightKg).round(),
                    isBodyWeightKnown: state.isBodyWeightKnown,
                    onViewSummary: () => unawaited(_showSummary(context, cubit)),
                  ),
                ),
                const VTGap.m(),
              ],
              for (final workout in state.workouts)
                for (final (index, workoutExercise) in workout.exercises.indexed) ...[
                  VTAppearEffect(
                    index: index + 1,
                    child: WorkoutExerciseCard(
                      workoutExercise: workoutExercise,
                      unitSystem: cubit.unitSystem,
                      lastSets: state.lastSetsByExercise[workoutExercise.exercise.id],
                      onTap: () async {
                        await context.pushRoute(
                          .exerciseWorkout,
                          extra: ExerciseWorkoutExtra(
                            workoutExercise: workoutExercise,
                            unitSystem: cubit.unitSystem,
                            defaultLoadKg: workoutExercise.exercise.equipment == Equipment.bodyOnly ? state.latestBodyWeightKg : null,
                          ),
                        );
                        await cubit.loadDate(state.date);
                      },
                      onRemove: () => cubit.removeExercise(workoutExerciseId: workoutExercise.id),
                      onToggleCompleted: (completed) => _setCompleted(context, cubit, workoutExercise: workoutExercise, completed: completed),
                      onRepeatSet: () => cubit.repeatLastSet(workoutExercise: workoutExercise),
                      onEditSet: (set) => showLogSetSheet(
                        context: context,
                        unitSystem: cubit.unitSystem,
                        isCardio: workoutExercise.exercise.category.isCardio,
                        set: set,
                        onSubmit: ({required input}) => cubit.updateSet(setId: set.id, input: input),
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

  Future<void> _showIntro(BuildContext context, WorkoutCubit cubit) async {
    final wantsRoutine = await context.pushRoute<bool>(.workoutIntro) ?? false;
    if (!context.mounted) {
      return;
    }
    await cubit.markIntroSeen();
    if (wantsRoutine && context.mounted) {
      await context.pushRoute(.routines);
      if (context.mounted) {
        await cubit.loadDate(cubit.state.date);
      }
    }
  }

  Future<void> _configureRest(BuildContext context) async {
    final timer = context.read<RestTimerCubit>();
    final rest = await showRestLengthSheet(context: context, current: timer.configuredRest);
    if (rest != null) {
      await timer.changeRest(rest);
    }
  }

  Future<void> _addExercise(BuildContext context, WorkoutCubit cubit) async {
    final exercise = await context.pushRoute<Exercise>(.exerciseSearch);
    if (exercise != null) {
      await cubit.addExercise(exercise);
    }
  }
}
