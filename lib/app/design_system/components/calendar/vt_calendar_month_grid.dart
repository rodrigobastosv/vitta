import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_day_cell.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';

class VTCalendarMonthGrid extends StatelessWidget {
  const VTCalendarMonthGrid({
    required this.month,
    required this.dayColor,
    required this.onDaySelected,
    this.selectedDay,
    this.isDayEnabled,
    this.weekBadge,
    super.key,
  });

  static const double _rowHeight = 44;

  final DateTime month;

  final Color? Function(DateTime day) dayColor;

  final ValueChanged<DateTime> onDaySelected;
  final DateTime? selectedDay;

  final bool Function(DateTime day)? isDayEnabled;

  final Widget Function(List<DateTime> daysInWeek)? weekBadge;

  @override
  Widget build(BuildContext context) {
    final weeks = _weeksOf(context.materialLocalizations.firstDayOfWeekIndex);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Column(
      children: [
        for (final (index, week) in weeks.indexed)
          VTAppearEffect(
            key: ValueKey('$month-$index'),
            delay: Duration(milliseconds: index * 40),
            child: SizedBox(
              height: _rowHeight,
              child: Row(
                children: [
                  for (final day in week)
                    Expanded(
                      child: day == null
                          ? const SizedBox.shrink()
                          : VTCalendarDayCell(
                              day: day,
                              valueColor: dayColor(day),
                              isToday: day == today,
                              isFuture: day.isAfter(today),
                              isSelected: day == selectedDay,
                              onTap: (isDayEnabled?.call(day) ?? true) ? () => onDaySelected(day) : null,
                            ),
                    ),
                  if (weekBadge != null) Center(child: weekBadge!(week.whereType<DateTime>().toList())),
                ],
              ),
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
    return [for (var start = 0; start < slots.length; start += DateTime.daysPerWeek) slots.sublist(start, start + DateTime.daysPerWeek)];
  }
}
