import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_search_field.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/exercise_detail/exercise_detail_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_search/exercise_search_state.dart';
import 'package:vitta/app/presentation/pages/exercise_search/widgets/exercise_search_result_tile.dart';
import 'package:vitta/app/presentation/pages/exercise_search/widgets/muscle_group_filter.dart';

class ExerciseSearchPage extends StatelessWidget {
  const ExerciseSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ExerciseSearchCubit, ExerciseSearchState, ExerciseSearchPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        ExerciseSearchShowLoading() => context.showLoading(),
        ExerciseSearchHideLoading() => context.hideLoading(),
        ExerciseSearchError(:final message) => context.showErrorToast(message: message),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.exerciseSearchTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.s),
              child: VTSearchField(hintText: l10n.exerciseSearchHint, onSubmitted: cubit.search, onChanged: cubit.queryChanged),
            ),
            MuscleGroupFilter(selected: state.muscleGroup, onChanged: cubit.changeMuscleGroup),
            const VTGap.s(),
            Expanded(child: _Results(state: state)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final ExerciseSearchState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (state) {
      ExerciseSearchState(results: final results?) when results.isEmpty => VTEmptyState(
        icon: Icons.fitness_center_outlined,
        title: l10n.exerciseSearchEmptyTitle,
        message: l10n.exerciseSearchEmptyMessage,
      ),
      ExerciseSearchState(results: final results?) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.xl),
        itemCount: results.length,
        separatorBuilder: (context, index) => const VTGap.s(),
        itemBuilder: (context, index) {
          final exercise = results[index];
          return ExerciseSearchResultTile(
            exercise: exercise,
            onTap: () => context.pushRoute(.exerciseDetail, extra: ExerciseDetailExtra(exercise: exercise)),
            onAdd: () => Navigator.of(context).pop<Exercise>(exercise),
          );
        },
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
