import 'package:flutter/material.dart';
import 'package:vitta/app/domain/diet/entities/calorie_average.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/diet_calendar_day_cell.dart';
import 'package:vitta/app/presentation/pages/diet_history/widgets/week_average_badge.dart';

class DietCalendarWeekRow extends StatelessWidget {
  const DietCalendarWeekRow({
    required this.days,
    required this.macrosByDate,
    required this.macroGoals,
    required this.onDaySelected,
    super.key,
  });

  final List<DateTime?> days;
  final Map<DateTime, DailyMacros> macrosByDate;
  final MacroGoals macroGoals;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final loggedDays = [
      for (final day in days)
        if (day != null && macrosByDate[day] != null) macrosByDate[day]!,
    ];
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: day == null
                  ? const SizedBox.shrink()
                  : DietCalendarDayCell(
                      day: day,
                      dayMacros: macrosByDate[day],
                      macroGoals: macroGoals,
                      isToday: day == todayOnly,
                      isFuture: day.isAfter(todayOnly),
                      onTap: () => onDaySelected(day),
                    ),
            ),
          Center(child: WeekAverageBadge(average: CalorieAverage.fromLoggedDays(loggedDays), macroGoals: macroGoals)),
        ],
      ),
    );
  }
}
