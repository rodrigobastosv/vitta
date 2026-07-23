import 'package:equatable/equatable.dart';

class LogReminderSchedule extends Equatable {
  const LogReminderSchedule({required this.isEnabled, required this.minuteOfDay, this.intervalHours});

  static const intervalEndMinuteOfDay = 22 * 60;
  static const intervalHourOptions = [1, 2, 3, 4];

  final bool isEnabled;
  final int minuteOfDay;
  final int? intervalHours;

  int get hour => minuteOfDay ~/ 60;

  int get minute => minuteOfDay % 60;

  bool get repeatsThroughTheDay => intervalHours != null;

  LogReminderSchedule copyWith({bool? isEnabled, int? minuteOfDay}) =>
      LogReminderSchedule(isEnabled: isEnabled ?? this.isEnabled, minuteOfDay: minuteOfDay ?? this.minuteOfDay, intervalHours: intervalHours);

  LogReminderSchedule withInterval(int? intervalHours) =>
      LogReminderSchedule(isEnabled: isEnabled, minuteOfDay: minuteOfDay, intervalHours: intervalHours);

  DateTime nextOccurrence({required DateTime now, required bool isLoggedToday}) {
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    if (isLoggedToday || !today.isAfter(now)) {
      return DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return today;
  }

  // A repeating schedule nudges through the whole day, so one log does not
  // settle it - drinking once is not drinking enough. A once-a-day schedule is
  // the opposite: it only fires while the day is still empty.
  List<DateTime> occurrencesFrom({required DateTime now, required bool isLoggedToday, required int maxOccurrences}) {
    final interval = intervalHours;
    if (interval == null) {
      return [nextOccurrence(now: now, isLoggedToday: isLoggedToday)];
    }
    final upcoming = <DateTime>[];
    for (var day = 0; day <= 1; day++) {
      for (var slotMinute = minuteOfDay; slotMinute <= intervalEndMinuteOfDay; slotMinute += interval * 60) {
        final occurrence = DateTime(now.year, now.month, now.day + day, slotMinute ~/ 60, slotMinute % 60);
        if (occurrence.isAfter(now) && upcoming.length < maxOccurrences) {
          upcoming.add(occurrence);
        }
      }
    }
    return upcoming;
  }

  @override
  List<Object?> get props => [isEnabled, minuteOfDay, intervalHours];
}
