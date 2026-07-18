import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_weekday_header.dart';
import 'package:vitta/app/design_system/components/calendar/vt_month_navigator.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder_history/reminder_history_state.dart';

class ReminderHistoryCalendarCard extends StatelessWidget {
  const ReminderHistoryCalendarCard({required this.cubit, required this.state, super.key});

  final ReminderHistoryCubit cubit;
  final ReminderHistoryState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        children: [
          VTMonthNavigator(
            month: state.month,
            canGoToNextMonth: true,
            onPreviousMonth: cubit.goToPreviousMonth,
            onNextMonth: cubit.goToNextMonth,
          ),
          const VTGap.s(),
          const VTCalendarWeekdayHeader(),
          const VTGap.s(),
          VTCalendarMonthGrid(
            month: state.month,
            selectedDay: state.selectedDay,
            dayColor: (day) => _dayColor(state.remindersInMonth[day], colorScheme),
            isDayEnabled: (day) => state.remindersInMonth[day]?.isNotEmpty ?? false,
            onDaySelected: cubit.selectDay,
          ),
        ],
      ),
    );
  }

  Color? _dayColor(List<Reminder>? reminders, ColorScheme colorScheme) {
    if (reminders == null || reminders.isEmpty) {
      return null;
    }
    return reminders.every((reminder) => reminder.isCompleted) ? VTColors.success : colorScheme.primary;
  }
}
