enum ReminderRecurrence {
  none(null),
  daily('daily'),
  weekdays('weekdays'),
  weekly('weekly'),
  monthly('monthly'),
  firstDayOfMonth('first_day_of_month'),
  lastDayOfMonth('last_day_of_month'),
  yearly('yearly');

  const ReminderRecurrence(this.wireValue);

  final String? wireValue;

  static ReminderRecurrence fromWireValue(String? value) =>
      ReminderRecurrence.values.firstWhere((recurrence) => recurrence.wireValue == value, orElse: () => .none);

  // Always the first occurrence strictly after `from`, so a monthly-on-the-last-day
  // reminder created mid-month lands on this month's end rather than skipping it.
  DateTime nextDate(DateTime from) => switch (this) {
    .none => from,
    .daily => DateTime(from.year, from.month, from.day + 1),
    .weekdays => _nextWeekday(from),
    .weekly => DateTime(from.year, from.month, from.day + 7),
    .monthly => _clampedDay(from.year, from.month + 1, from.day),
    .firstDayOfMonth => DateTime(from.year, from.month + 1),
    .lastDayOfMonth => _nextMonthEnd(from),
    .yearly => _clampedDay(from.year + 1, from.month, from.day),
  };

  static DateTime _nextWeekday(DateTime from) {
    var next = DateTime(from.year, from.month, from.day + 1);
    while (next.weekday > DateTime.friday) {
      next = DateTime(next.year, next.month, next.day + 1);
    }
    return next;
  }

  // Day 0 of the following month is the last day of the given one, and DateTime
  // normalizes a month past 12 into the next year, so December needs no branch.
  static DateTime _monthEnd(int year, int month) => DateTime(year, month + 1, 0);

  static DateTime _nextMonthEnd(DateTime from) {
    final thisMonthEnd = _monthEnd(from.year, from.month);
    return from.day < thisMonthEnd.day ? thisMonthEnd : _monthEnd(from.year, from.month + 1);
  }

  static DateTime _clampedDay(int year, int month, int day) {
    final lastDay = _monthEnd(year, month).day;
    return DateTime(year, month, day < lastDay ? day : lastDay);
  }
}
