import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_week_badge.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_weekday_header.dart';
import 'package:vitta/app/design_system/components/calendar/vt_month_navigator.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_cubit.dart';
import 'package:vitta/app/presentation/pages/workout_history/workout_history_state.dart';

class WorkoutHistoryCalendarCard extends StatelessWidget {
  const WorkoutHistoryCalendarCard({required this.cubit, required this.state, super.key});

  final WorkoutHistoryCubit cubit;
  final WorkoutHistoryState state;

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
            dayColor: (day) => _trained(day) ? context.colorScheme.primary : null,
            isDayEnabled: (_) => false,
            onDaySelected: (_) {},
            weekBadge: (daysInWeek) => _weekBadge(context, daysInWeek),
          ),
        ],
      ),
    );
  }

  bool _trained(DateTime day) => state.workoutsInMonth[day]?.hasData ?? false;

  Widget _weekBadge(BuildContext context, List<DateTime> daysInWeek) {
    final l10n = context.l10n;
    final sessionCount = daysInWeek.where(_trained).length;
    if (sessionCount == 0) {
      return const VTCalendarWeekBadge();
    }
    return VTCalendarWeekBadge(label: '$sessionCount', color: context.colorScheme.primary, tooltip: l10n.workoutHistoryWeekSessions(sessionCount));
  }
}
