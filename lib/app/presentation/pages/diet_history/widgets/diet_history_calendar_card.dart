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
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_state.dart';

class DietHistoryCalendarCard extends StatelessWidget {
  const DietHistoryCalendarCard({required this.cubit, required this.state, required this.onDaySelected, super.key});

  final DietHistoryCubit cubit;
  final DietHistoryState state;
  final ValueChanged<DateTime> onDaySelected;

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
            onDaySelected: onDaySelected,
            weekBadge: (daysInWeek) => _weekBadge(context, daysInWeek),
          ),
        ],
      ),
    );
  }

  Color? _dayColor(DateTime day) {
    final macros = state.macrosInMonth[day];
    if (macros == null || macros.entries.isEmpty) {
      return null;
    }
    return macros.adherenceTo(state.macroGoals).color;
  }

  Widget _weekBadge(BuildContext context, List<DateTime> daysInWeek) {
    final l10n = context.l10n;
    final average = DailyGoalAverage.fromValues([
      for (final day in daysInWeek)
        if (state.macrosInMonth[day] case final macros? when macros.entries.isNotEmpty) macros.totalCalories,
    ]);
    if (!average.hasData) {
      return const VTCalendarWeekBadge();
    }
    final calories = average.average.round();
    return VTCalendarWeekBadge(
      label: l10n.dietWeekAverageShort(calories),
      color: state.macroGoals.calorieGoal <= 0 ? null : GoalAdherence.forRatio(average.average / state.macroGoals.calorieGoal).color,
      tooltip: l10n.dietWeekAverageTooltip(calories, average.loggedDayCount),
    );
  }
}
