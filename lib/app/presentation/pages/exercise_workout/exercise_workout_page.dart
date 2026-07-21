import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_remote_image.dart';
import 'package:vitta/app/design_system/components/general/vt_rest_timer.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_state.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/log_set_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/rest_length_sheet.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/set_prefill.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_set_row.dart';

class ExerciseWorkoutPage extends StatelessWidget {
  const ExerciseWorkoutPage({required this.extra, super.key});

  final ExerciseWorkoutExtra extra;

  Future<void> _finish(BuildContext context, ExerciseWorkoutCubit cubit, ExerciseWorkoutState state) async {
    final navigator = Navigator.of(context);
    final wasCompleted = state.isCompleted;
    final succeeded = await cubit.setCompleted(completed: !wasCompleted);
    if (succeeded && !wasCompleted) {
      navigator.pop();
    }
  }

  Future<void> _configureRest(BuildContext context) async {
    final timer = context.read<RestTimerCubit>();
    final rest = await showRestLengthSheet(context: context, current: timer.configuredRest);
    if (rest != null) {
      await timer.changeRest(rest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ExerciseWorkoutCubit, ExerciseWorkoutState, ExerciseWorkoutPresentationEvent>(
      cubitParam: extra,
      onPresentation: (context, event) => switch (event) {
        ExerciseWorkoutShowLoading() => context.showLoading(),
        ExerciseWorkoutHideLoading() => context.hideLoading(),
        ExerciseWorkoutSetLogged() => context.read<RestTimerCubit>().start(label: extra.workoutExercise.exercise.nameFor(l10n.localeName)),
        ExerciseWorkoutError(:final message) => context.showErrorToast(message: message),
      },
      builder: (context, cubit, state) {
        final exercise = state.workoutExercise.exercise;
        final instructions = exercise.instructionsFor(l10n.localeName);
        return PopScope(
          onPopInvokedWithResult: (didPop, _) => didPop ? null : null,
          child: Scaffold(
            appBar: AppBar(
              title: Text(exercise.nameFor(l10n.localeName)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.show_chart),
                  tooltip: l10n.workoutProgressionTitle,
                  onPressed: () => context.pushRoute(.exerciseProgression, extra: ExerciseProgressionExtra(exercise: exercise)),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(VTSpacing.m),
              children: [
                if (exercise.imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: .horizontal,
                      itemCount: exercise.imageUrls.length,
                      separatorBuilder: (context, index) => const SizedBox(width: VTSpacing.s),
                      itemBuilder: (context, index) => VTRemoteImage(
                        imageUrl: exercise.imageUrls[index],
                        placeholderIcon: Icons.fitness_center_outlined,
                        width: 260,
                        height: 180,
                        borderRadius: VTRadius.borderRadiusM,
                      ),
                    ),
                  ),
                  const VTGap.m(),
                ],
                BlocBuilder<RestTimerCubit, RestTimerState>(
                  builder: (context, timer) => timer.isRunning
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: VTSpacing.m),
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
                Text(l10n.workoutSetsLabel, style: VTTextStyles.overline(context)),
                const VTGap.s(),
                VTCard(
                  child: Column(
                    children: [
                      if (state.workoutExercise.sets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
                          child: Text(l10n.workoutNoSetsMessage, style: VTTextStyles.caption(context)),
                        )
                      else
                        for (final (index, set) in state.workoutExercise.sets.indexed)
                          WorkoutSetRow(
                            position: index + 1,
                            set: set,
                            color: exercise.primaryMuscles.firstOrNull?.region.color ?? Theme.of(context).colorScheme.primary,
                            unitSystem: extra.unitSystem,
                            onEdit: () => showLogSetSheet(
                              context: context,
                              unitSystem: extra.unitSystem,
                              set: set,
                              onSubmit: ({required reps, required weightKg}) => cubit.updateSet(setId: set.id, reps: reps, weightKg: weightKg),
                            ),
                            onDelete: () => cubit.deleteSet(setId: set.id),
                          ),
                    ],
                  ),
                ),
                const VTGap.m(),
                Row(
                  children: [
                    if (state.workoutExercise.sets.isNotEmpty) ...[
                      Expanded(
                        child: VTPrimaryButton(label: l10n.workoutRepeatSetAction, onPressed: cubit.repeatLastSet),
                      ),
                      const VTGap.s(),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showLogSetSheet(
                          context: context,
                          unitSystem: extra.unitSystem,
                          defaultLoadKg: state.workoutExercise.sets.lastOrNull?.weightKg ?? extra.defaultLoadKg,
                          defaultReps: state.workoutExercise.sets.lastOrNull?.reps,
                          prefill: switch ((state.workoutExercise.sets.lastOrNull, extra.defaultLoadKg)) {
                            (final _?, _) => SetPrefill.lastSet,
                            (null, final bodyWeight?) when bodyWeight > 0 => SetPrefill.bodyWeight,
                            _ => SetPrefill.none,
                          },
                          onSubmit: ({required reps, required weightKg}) => cubit.logSet(reps: reps, weightKg: weightKg),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.workoutAddSet),
                      ),
                    ),
                  ],
                ),
                if (instructions.isNotEmpty) ...[
                  const VTGap.l(),
                  Text(l10n.workoutInstructionsTitle, style: VTTextStyles.overline(context)),
                  const VTGap.s(),
                  for (final (index, step) in instructions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: VTSpacing.s),
                      child: Text('${index + 1}. $step', style: VTTextStyles.body(context)),
                    ),
                ],
                const VTGap.xxl(),
              ],
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.all(VTSpacing.m),
              child: VTPrimaryButton(
                label: state.isCompleted ? l10n.workoutReopenExerciseAction : l10n.workoutCompleteExerciseAction,
                icon: state.isCompleted ? Icons.undo : Icons.check,
                onPressed: state.canComplete || state.isCompleted ? () => _finish(context, cubit, state) : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
