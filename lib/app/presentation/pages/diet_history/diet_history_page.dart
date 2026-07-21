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
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/trend_range_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/diet_day/diet_day_extra.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_state.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/calories_trend_card.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_history_calendar_card.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/macros_trend_card.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/meal_split_card.dart';

class DietHistoryPage extends StatelessWidget {
  const DietHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<DietHistoryCubit, DietHistoryState, DietHistoryPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case DietHistoryShowLoading():
            context.showLoading();
          case DietHistoryHideLoading():
            context.hideLoading();
          case DietHistoryError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<DietHistoryCubit>().refresh);
        }
      },
      builder: (context, cubit, state) {
        final trendDays = _trendDays(state);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.dietHistoryTitle)),
          body: !state.hasData
              ? VTEmptyState(
                  icon: Icons.restaurant_outlined,
                  title: l10n.dietHistoryEmptyTitle,
                  message: l10n.dietHistoryEmptyMessage,
                  actionLabel: l10n.dietHistoryEmptyAction,
                  onAction: () => Navigator.of(context).pop(),
                )
              : ListView(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  children: [
                    VTAppearEffect(
                      child: DietHistoryCalendarCard(
                        cubit: cubit,
                        state: state,
                        onDaySelected: (day) => context.pushRoute(
                          .dietDay,
                          extra: DietDayExtra(date: day, dailyMacros: state.macrosInMonth[day]!, macroGoals: state.macroGoals),
                        ),
                      ),
                    ),
                    const VTGap.l(),
                    Text(l10n.dietHistoryTrendsTitle, style: VTTextStyles.title(context)),
                    const VTGap.m(),
                    Center(
                      child: TrendRangeSelector(selected: state.trendRange, onSelected: cubit.changeTrendRange),
                    ),
                    const VTGap.m(),
                    VTAppearEffect(
                      key: ValueKey('calories-${state.trendRange}'),
                      child: CaloriesTrendCard(days: trendDays, macrosByDate: state.macrosInTrendRange, macroGoals: state.macroGoals),
                    ),
                    const VTGap.m(),
                    VTAppearEffect(
                      key: ValueKey('macros-${state.trendRange}'),
                      index: 1,
                      child: MacrosTrendCard(days: trendDays, macrosByDate: state.macrosInTrendRange),
                    ),
                    const VTGap.m(),
                    VTAppearEffect(
                      key: ValueKey('meal-split-${state.trendRange}'),
                      index: 2,
                      child: MealSplitCard(days: trendDays, macrosByDate: state.macrosInTrendRange),
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<DateTime> _trendDays(DietHistoryState state) {
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    return [for (var offset = state.trendRange.days - 1; offset >= 0; offset--) to.subtract(Duration(days: offset))];
  }
}
