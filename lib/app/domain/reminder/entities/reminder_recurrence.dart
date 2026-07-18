enum ReminderRecurrence {
  none(null),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const ReminderRecurrence(this.wireValue);

  final String? wireValue;

  static ReminderRecurrence fromWireValue(String? value) =>
      ReminderRecurrence.values.firstWhere((recurrence) => recurrence.wireValue == value, orElse: () => .none);

  DateTime nextDate(DateTime from) => switch (this) {
    .none => from,
    .daily => DateTime(from.year, from.month, from.day + 1),
    .weekly => DateTime(from.year, from.month, from.day + 7),
    .monthly => _nextMonth(from),
  };

  static DateTime _nextMonth(DateTime from) {
    final month = from.month + 1;
    final year = month > 12 ? from.year + 1 : from.year;
    final normalizedMonth = month > 12 ? 1 : month;
    final lastDay = DateTime(year, normalizedMonth + 1, 0).day;
    return DateTime(year, normalizedMonth, from.day < lastDay ? from.day : lastDay);
  }
}
