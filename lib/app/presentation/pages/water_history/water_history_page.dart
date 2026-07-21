import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_cubit.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_state.dart';
import 'package:vitta/app/presentation/pages/water_history/widgets/water_history_calendar_card.dart';
import 'package:vitta/app/presentation/pages/water_history/widgets/water_trend_card.dart';

class WaterHistoryPage extends StatelessWidget {
  const WaterHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<WaterHistoryCubit, WaterHistoryState, WaterHistoryPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case WaterHistoryShowLoading():
            context.showLoading();
          case WaterHistoryHideLoading():
            context.hideLoading();
          case WaterHistoryError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<WaterHistoryCubit>().refresh);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.waterHistoryTitle)),
        body: VTRefreshable(
          onRefresh: cubit.refresh,
          hasData: state.hasData,
          emptyState: VTEmptyState(
            icon: Icons.water_drop_outlined,
            title: l10n.waterHistoryEmptyTitle,
            message: l10n.waterHistoryEmptyMessage,
            actionLabel: l10n.waterHistoryEmptyAction,
            onAction: () => Navigator.of(context).pop(),
          ),
          children: [
            WaterHistoryCalendarCard(cubit: cubit, state: state),
            const VTGap.l(),
            Text(l10n.dietHistoryTrendsTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
            const VTGap.m(),
            WaterTrendCard(days: cubit.trendDays, waterByDate: state.waterInTrendRange, dailyGoalMl: state.dailyGoalMl),
          ],
        ),
      ),
    );
  }
}
