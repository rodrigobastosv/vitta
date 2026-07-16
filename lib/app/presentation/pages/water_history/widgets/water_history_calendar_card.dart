import 'package:flutter/material.dart';
import 'package:vitta/app/core/goals/daily_goal_average.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_week_badge.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_weekday_header.dart';
import 'package:vitta/app/design_system/components/calendar/vt_month_navigator.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_cubit.dart';
import 'package:vitta/app/presentation/pages/water_history/water_history_state.dart';

class WaterHistoryCalendarCard extends StatelessWidget {
  const WaterHistoryCalendarCard({required this.cubit, required this.state, super.key});

  final WaterHistoryCubit cubit;
  final WaterHistoryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        children: [
          VTMonthNavigator(
            month: state.month,
            canGoToNextMonth: !cubit.isViewingCurrentMonth,
            onPreviousMonth: cubit.goToPreviousMonth,
            onNextMonth: cubit.goToNextMonth,
          ),
          const VTGap.s(),
          VTCalendarWeekdayHeader(weekColumnLabel: l10n.dietWeekColumnLabel),
          const VTGap.s(),
          VTCalendarMonthGrid(
            month: state.month,
            dayColor: _dayColor,
            isDayEnabled: (_) => false,
            onDaySelected: (_) {},
            weekBadge: (daysInWeek) => _weekBadge(context, daysInWeek),
          ),
        ],
      ),
    );
  }

  Color? _dayColor(DateTime day) {
    final water = state.waterInMonth[day];
    if (water == null || water.entries.isEmpty) {
      return null;
    }
    return state.dailyGoalMl <= 0 ? null : GoalAdherence.forRatio(water.totalMl / state.dailyGoalMl).color;
  }

  Widget _weekBadge(BuildContext context, List<DateTime> daysInWeek) {
    final l10n = context.l10n;
    final average = DailyGoalAverage.fromValues([
      for (final day in daysInWeek)
        if (state.waterInMonth[day] case final water? when water.entries.isNotEmpty) water.totalMl,
    ]);
    if (!average.hasData) {
      return const VTCalendarWeekBadge();
    }
    return VTCalendarWeekBadge(
      label: l10n.waterWeekAverageShort(average.average.round()),
      color: state.dailyGoalMl <= 0 ? null : GoalAdherence.forRatio(average.average / state.dailyGoalMl).color,
      tooltip: l10n.waterWeekAverageTooltip(average.average.round(), average.loggedDayCount),
    );
  }
}
