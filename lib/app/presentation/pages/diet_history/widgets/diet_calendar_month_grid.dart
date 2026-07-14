import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_calendar_week_row.dart';

class DietCalendarMonthGrid extends StatelessWidget {
  const DietCalendarMonthGrid({
    required this.month,
    required this.macrosByDate,
    required this.macroGoals,
    required this.onDaySelected,
    super.key,
  });

  final DateTime month;
  final Map<DateTime, DailyMacros> macrosByDate;
  final MacroGoals macroGoals;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final weeks = _weeksOf(context.materialLocalizations.firstDayOfWeekIndex);
    return Column(
      children: [
        for (final (index, week) in weeks.indexed)
          VTAppearEffect(
            key: ValueKey('$month-$index'),
            delay: Duration(milliseconds: index * 40),
            child: DietCalendarWeekRow(
              days: week,
              macrosByDate: macrosByDate,
              macroGoals: macroGoals,
              onDaySelected: onDaySelected,
            ),
          ),
      ],
    );
  }

  List<List<DateTime?>> _weeksOf(int firstDayOfWeekIndex) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekdaySundayIndex = DateTime(month.year, month.month).weekday % DateTime.daysPerWeek;
    final leadingBlanks = (firstWeekdaySundayIndex - firstDayOfWeekIndex + DateTime.daysPerWeek) % DateTime.daysPerWeek;
    final slots = <DateTime?>[
      ...List<DateTime?>.filled(leadingBlanks, null),
      for (var day = 1; day <= daysInMonth; day++) DateTime(month.year, month.month, day),
    ];
    while (slots.length % DateTime.daysPerWeek != 0) {
      slots.add(null);
    }
    return [
      for (var start = 0; start < slots.length; start += DateTime.daysPerWeek) slots.sublist(start, start + DateTime.daysPerWeek),
    ];
  }
}
