import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_state.dart';
import 'package:vitta/app/presentation/pages/sleep_history/widgets/sleep_duration_trend_card.dart';
import 'package:vitta/app/presentation/pages/sleep_history/widgets/sleep_history_calendar_card.dart';
import 'package:vitta/app/presentation/pages/sleep_history/widgets/sleep_quality_split_card.dart';

class SleepHistoryPage extends StatelessWidget {
  const SleepHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<SleepHistoryCubit, SleepHistoryState, SleepHistoryPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case SleepHistoryShowLoading():
            context.showLoading();
          case SleepHistoryHideLoading():
            context.hideLoading();
          case SleepHistoryError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<SleepHistoryCubit>().refresh);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.sleepHistoryTitle)),
        body: !state.hasData
            ? VTEmptyState(
                icon: Icons.bedtime_outlined,
                title: l10n.sleepHistoryEmptyTitle,
                message: l10n.sleepHistoryEmptyMessage,
                actionLabel: l10n.sleepHistoryEmptyAction,
                onAction: () => Navigator.of(context).pop(),
              )
            : ListView(
                padding: const EdgeInsets.all(VTSpacing.m),
                children: [
                  SleepHistoryCalendarCard(cubit: cubit, state: state),
                  const VTGap.l(),
                  Text(l10n.dietHistoryTrendsTitle, style: VTTextStyles.title(context)),
                  const VTGap.m(),
                  TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
                  const VTGap.m(),
                  SleepDurationTrendCard(days: cubit.trendDays, sleepByDate: state.sleepInTrendRange, durationGoalHours: state.durationGoalHours),
                  const VTGap.m(),
                  SleepQualitySplitCard(days: cubit.trendDays, sleepByDate: state.sleepInTrendRange),
                ],
              ),
      ),
    );
  }
}
