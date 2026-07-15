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
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_cubit.dart';
import 'package:vitta/app/presentation/pages/sleep_history/sleep_history_state.dart';

class SleepHistoryCalendarCard extends StatelessWidget {
  const SleepHistoryCalendarCard({required this.cubit, required this.state, super.key});

  final SleepHistoryCubit cubit;
  final SleepHistoryState state;

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

  Color? _adherenceColor(double hours) =>
      state.durationGoalHours <= 0 ? null : GoalAdherence.forRatio(hours / state.durationGoalHours).color;

  Color? _dayColor(DateTime day) {
    final sleep = state.sleepInMonth[day];
    if (sleep == null || sleep.entries.isEmpty) {
      return null;
    }
    return _adherenceColor(sleep.totalHours);
  }

  Widget _weekBadge(BuildContext context, List<DateTime> daysInWeek) {
    final l10n = context.l10n;
    final average = DailyGoalAverage.fromValues([
      for (final day in daysInWeek)
        if (state.sleepInMonth[day] case final sleep? when sleep.entries.isNotEmpty) sleep.totalHours,
    ]);
    if (!average.hasData) {
      return const VTCalendarWeekBadge();
    }
    return VTCalendarWeekBadge(
      label: l10n.sleepHoursShort(average.average.toStringAsFixed(1)),
      color: _adherenceColor(average.average),
      tooltip: l10n.sleepWeekAverageTooltip(average.average.toStringAsFixed(1), average.loggedDayCount),
    );
  }
}
