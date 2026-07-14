import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_calendar_day_cell.dart';

class CopyMealsMonthGrid extends StatelessWidget {
  const CopyMealsMonthGrid({
    required this.month,
    required this.macrosByDate,
    required this.macroGoals,
    required this.selectedDate,
    required this.targetDate,
    required this.onDaySelected,
    super.key,
  });

  final DateTime month;
  final Map<DateTime, DailyMacros> macrosByDate;
  final MacroGoals macroGoals;
  final DateTime? selectedDate;
  final DateTime targetDate;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeekIndex = context.materialLocalizations.firstDayOfWeekIndex;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekdaySundayIndex = DateTime(month.year, month.month).weekday % DateTime.daysPerWeek;
    final leadingBlanks = (firstWeekdaySundayIndex - firstDayOfWeekIndex + DateTime.daysPerWeek) % DateTime.daysPerWeek;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: DateTime.daysPerWeek),
      itemCount: leadingBlanks + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingBlanks) {
          return const SizedBox.shrink();
        }
        final day = DateTime(month.year, month.month, index - leadingBlanks + 1);
        return DietCalendarDayCell(
          day: day,
          dayMacros: macrosByDate[day],
          macroGoals: macroGoals,
          isToday: day == today,
          isFuture: day.isAfter(today),
          isSelected: day == selectedDate,
          onTap: day == targetDate ? null : () => onDaySelected(day),
        );
      },
    );
  }
}
