import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/exercise_progression_list_state.dart';
import 'package:vitta/app/presentation/pages/exercise_progression_list/widgets/logged_exercise_tile.dart';

class ExerciseProgressionListPage extends StatelessWidget {
  const ExerciseProgressionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ExerciseProgressionListCubit, ExerciseProgressionListState, ExerciseProgressionListPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case ExerciseProgressionListShowLoading():
            context.showLoading();
          case ExerciseProgressionListHideLoading():
            context.hideLoading();
          case ExerciseProgressionListError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<ExerciseProgressionListCubit>().load);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.workoutProgressionListTitle)),
        body: state.exercises.isEmpty
            ? VTEmptyState(
                icon: Icons.fitness_center_outlined,
                title: l10n.workoutProgressionListEmptyTitle,
                message: l10n.workoutProgressionListEmptyMessage,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(VTSpacing.m),
                itemCount: state.exercises.length,
                separatorBuilder: (context, index) => const VTGap.s(),
                itemBuilder: (context, index) {
                  final exercise = state.exercises[index];
                  return VTAppearEffect(
                    index: index,
                    child: LoggedExerciseTile(
                      exercise: exercise,
                      onTap: () => context.pushRoute(.exerciseProgression, extra: ExerciseProgressionExtra(exercise: exercise)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
