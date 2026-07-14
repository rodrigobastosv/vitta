import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_state.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_month_grid.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_weekday_header.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/month_navigator.dart';

class CopyMealsCalendarCard extends StatelessWidget {
  const CopyMealsCalendarCard({required this.cubit, required this.state, super.key});

  final CopyMealsCubit cubit;
  final CopyMealsState state;

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
        const CopyMealsWeekdayHeader(),
        const VTGap.s(),
        CopyMealsMonthGrid(
          month: state.month,
          macrosByDate: state.macrosByDate,
          macroGoals: state.macroGoals,
          selectedDate: state.sourceDate,
          targetDate: state.targetDate,
          onDaySelected: cubit.selectSourceDate,
        ),
      ],
    ),
  );
}
