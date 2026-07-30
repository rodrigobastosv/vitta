import 'package:equatable/equatable.dart';

// How many days in a row food has been logged. Derived from the days that
// already have entries, never stored - the same call MacroGoals.calorieGoal and
// MacroGap make - so there is no counter that can drift out of sync with the
// diary it describes, and nothing to migrate.
class LoggingStreak extends Equatable {
  const LoggingStreak({required this.days});

  // A day with nothing logged *yet* does not break the streak: counting starts
  // from yesterday instead, so the figure does not read zero at 8 AM before
  // anyone has eaten. The streak is only over once yesterday is unlogged too.
  factory LoggingStreak.from({required Set<DateTime> loggedDays, required DateTime today}) {
    final logged = {for (final day in loggedDays) DateTime(day.year, day.month, day.day)};
    final startOfToday = DateTime(today.year, today.month, today.day);
    var cursor = logged.contains(startOfToday) ? startOfToday : _dayBefore(startOfToday);
    var days = 0;
    while (logged.contains(cursor)) {
      days++;
      cursor = _dayBefore(cursor);
    }
    return LoggingStreak(days: days);
  }

  static const none = LoggingStreak(days: 0);

  // Rebuilding the date rather than subtracting a Duration: a day is not always
  // 24 hours, and across a DST boundary midnight minus one day lands on 23:00 of
  // the previous day, which then matches none of the normalized keys above.
  static DateTime _dayBefore(DateTime day) => DateTime(day.year, day.month, day.day - 1);

  final int days;

  bool get isActive => days > 0;

  @override
  List<Object?> get props => [days];
}
