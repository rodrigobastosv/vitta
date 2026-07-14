import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_cubit.dart';
import 'package:vitta/app/presentation/pages/diet_history/diet_history_state.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_calendar_month_grid.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_calendar_weekday_header.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/month_navigator.dart';

class DietHistoryCalendarCard extends StatelessWidget {
  const DietHistoryCalendarCard({required this.cubit, required this.state, required this.onDaySelected, super.key});

  final DietHistoryCubit cubit;
  final DietHistoryState state;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) => VTCard(
    child: Column(
      children: [
        MonthNavigator(
          month: state.month,
          canGoToNextMonth: !cubit.isViewingCurrentMonth,
          onPreviousMonth: cubit.goToPreviousMonth,
          onNextMonth: cubit.goToNextMonth,
        ),
        const VTGap.s(),
        const DietCalendarWeekdayHeader(),
        const VTGap.s(),
        DietCalendarMonthGrid(
          month: state.month,
          macrosByDate: state.macrosInMonth,
          macroGoals: state.macroGoals,
          onDaySelected: onDaySelected,
        ),
      ],
    ),
  );
}
