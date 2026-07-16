import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_month_grid.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_weekday_header.dart';
import 'package:vitta/app/design_system/components/calendar/vt_month_navigator.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_state.dart';

class CopyMealsCalendarCard extends StatelessWidget {
  const CopyMealsCalendarCard({required this.cubit, required this.state, super.key});

  final CopyMealsCubit cubit;
  final CopyMealsState state;

  @override
  Widget build(BuildContext context) => VTCard(
    child: Column(
      children: [
        VTMonthNavigator(
          month: state.month,
          canGoToNextMonth: !cubit.isViewingCurrentMonth,
          onPreviousMonth: cubit.goToPreviousMonth,
          onNextMonth: cubit.goToNextMonth,
        ),
        const VTGap.s(),
        const VTCalendarWeekdayHeader(),
        const VTGap.s(),
        VTCalendarMonthGrid(
          month: state.month,
          dayColor: _dayColor,
          selectedDay: state.sourceDate,
          isDayEnabled: (day) => day != state.targetDate,
          onDaySelected: cubit.selectSourceDate,
        ),
      ],
    ),
  );

  Color? _dayColor(DateTime day) {
    final macros = state.macrosByDate[day];
    if (macros == null || macros.entries.isEmpty) {
      return null;
    }
    return macros.adherenceTo(state.macroGoals).color;
  }
}
