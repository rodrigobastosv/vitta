import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';

void main() {
  test('an unlogged tracker is reminded later the same day', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 20 * 60);

    expect(
      schedule.nextOccurrence(now: DateTime(2026, 7, 23, 14, 30), isLoggedToday: false),
      DateTime(2026, 7, 23, 20),
    );
  });

  test('a tracker already logged today is pushed to tomorrow', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 20 * 60);

    expect(
      schedule.nextOccurrence(now: DateTime(2026, 7, 23, 14, 30), isLoggedToday: true),
      DateTime(2026, 7, 24, 20),
    );
  });

  test('a time that already passed today is pushed to tomorrow', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60);

    expect(
      schedule.nextOccurrence(now: DateTime(2026, 7, 23, 14, 30), isLoggedToday: false),
      DateTime(2026, 7, 24, 9),
    );
  });

  test('the exact reminder minute counts as passed rather than firing instantly', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 15 * 60 + 30);

    expect(
      schedule.nextOccurrence(now: DateTime(2026, 7, 23, 15, 30), isLoggedToday: false),
      DateTime(2026, 7, 24, 15, 30),
    );
  });

  test('tomorrow means the same wall-clock time on the next calendar day', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60);

    expect(
      schedule.nextOccurrence(now: DateTime(2026, 12, 31, 23, 50), isLoggedToday: false),
      DateTime(2027, 1, 1, 9),
    );
  });

  test('hour and minute are read off the minute of day', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 21 * 60 + 45);

    expect(schedule.hour, 21);
    expect(schedule.minute, 45);
  });
}
