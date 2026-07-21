import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_state.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/widgets/exercise_progression_chart_card.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/widgets/exercise_progression_records_card.dart';

class ExerciseProgressionPage extends StatelessWidget {
  const ExerciseProgressionPage({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ExerciseProgressionCubit, ExerciseProgressionState, ExerciseProgressionPresentationEvent>(
      cubitParam: exercise,
      onPresentation: (context, event) {
        switch (event) {
          case ExerciseProgressionShowLoading():
            context.showLoading();
          case ExerciseProgressionHideLoading():
            context.hideLoading();
          case ExerciseProgressionError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<ExerciseProgressionCubit>().load);
        }
      },
      builder: (context, cubit, state) {
        final colorScheme = context.colorScheme;
        final accent = state.exercise.primaryMuscles.firstOrNull?.region.color ?? colorScheme.primary;
        final progression = state.progression;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.workoutProgressionTitle)),
          body: !state.isLoaded
              ? const Padding(padding: EdgeInsets.all(VTSpacing.m), child: ListSkeleton(headerHeight: 200, rows: 2))
              : !progression.hasData
              ? VTEmptyState(icon: Icons.show_chart, title: l10n.workoutProgressionEmptyTitle, message: l10n.workoutProgressionEmptyMessage)
              : ListView(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  children: [
                    VTAppearEffect(
                      child: ExerciseProgressionRecordsCard(progression: progression, color: accent, unitSystem: cubit.unitSystem),
                    ),
                    const VTGap.m(),
                    VTAppearEffect(
                      index: 1,
                      child: ExerciseProgressionChartCard(
                        title: l10n.workoutProgressionE1rmTitle,
                        points: progression.points,
                        valueOf: (point) => point.estimatedOneRepMax,
                        color: accent,
                        unitSystem: cubit.unitSystem,
                      ),
                    ),
                    const VTGap.m(),
                    VTAppearEffect(
                      index: 2,
                      child: ExerciseProgressionChartCard(
                        title: l10n.workoutProgressionHeaviestTitle,
                        points: progression.points,
                        valueOf: (point) => point.heaviestWeightKg,
                        color: colorScheme.primary,
                        unitSystem: cubit.unitSystem,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
