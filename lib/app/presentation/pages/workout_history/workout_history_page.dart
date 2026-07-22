import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/history_skeleton.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/workout_history/widgets/muscle_region_split_card.dart';
import 'package:vitta/app/presentation/pages/workout_history/widgets/workout_cardio_trend_card.dart';
import 'package:vitta/app/presentation/pages/workout_history/widgets/workout_history_calendar_card.dart';
import 'package:vitta/app/presentation/pages/workout_history/widgets/workout_volume_trend_card.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_state.dart';

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<WorkoutHistoryCubit, WorkoutHistoryState, WorkoutHistoryPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case WorkoutHistoryShowLoading():
            context.showLoading();
          case WorkoutHistoryHideLoading():
            context.hideLoading();
          case WorkoutHistoryError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<WorkoutHistoryCubit>().refresh);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.workoutHistoryTitle)),
        body: VTRefreshable(
          onRefresh: cubit.refresh,
          hasData: state.hasData,
          isLoaded: state.isLoaded,
          skeleton: const HistorySkeleton(),
          emptyState: VTEmptyState(
            icon: Icons.fitness_center_outlined,
            title: l10n.workoutHistoryEmptyTitle,
            message: l10n.workoutHistoryEmptyMessage,
            actionLabel: l10n.workoutHistoryEmptyAction,
            onAction: () => Navigator.of(context).pop(),
          ),
          children: [
            WorkoutHistoryCalendarCard(cubit: cubit, state: state),
            const VTGap.l(),
            Text(l10n.dietHistoryTrendsTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
            const VTGap.m(),
            WorkoutVolumeTrendCard(days: cubit.trendDays, workoutsByDate: state.workoutsInTrendRange, unitSystem: cubit.unitSystem),
            const VTGap.m(),
            WorkoutCardioTrendCard(days: cubit.trendDays, workoutsByDate: state.workoutsInTrendRange),
            const VTGap.m(),
            MuscleRegionSplitCard(days: cubit.trendDays, workoutsByDate: state.workoutsInTrendRange),
          ],
        ),
      ),
    );
  }
}
