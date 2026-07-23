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

  test('a once-a-day schedule occupies a single slot', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 20 * 60);

    expect(
      schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 14), isLoggedToday: false, maxOccurrences: 12),
      [DateTime(2026, 7, 23, 20)],
    );
  });

  test('a repeating schedule fills the rest of the day at its interval', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60, intervalHours: 4);

    expect(
      schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 10), isLoggedToday: false, maxOccurrences: 12).take(3),
      [DateTime(2026, 7, 23, 13), DateTime(2026, 7, 23, 17), DateTime(2026, 7, 23, 21)],
    );
  });

  test('a repeating schedule carries on into tomorrow once today runs out', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60, intervalHours: 4);

    expect(
      schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 22), isLoggedToday: false, maxOccurrences: 12).first,
      DateTime(2026, 7, 24, 9),
    );
  });

  test('a repeating schedule stops at the end of its window rather than through the night', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60, intervalHours: 4);

    final occurrences = schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 8), isLoggedToday: false, maxOccurrences: 12);

    expect(occurrences.every((occurrence) => occurrence.hour * 60 + occurrence.minute <= LogReminderSchedule.intervalEndMinuteOfDay), isTrue);
  });

  test('a repeating schedule keeps nudging a day that already has a log', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 9 * 60, intervalHours: 3);

    expect(
      schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 10), isLoggedToday: true, maxOccurrences: 12).first,
      DateTime(2026, 7, 23, 12),
    );
  });

  test('no more slots are handed out than were asked for', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 8 * 60, intervalHours: 1);

    expect(schedule.occurrencesFrom(now: DateTime(2026, 7, 23, 7), isLoggedToday: false, maxOccurrences: 5).length, 5);
  });

  test('hour and minute are read off the minute of day', () {
    const schedule = LogReminderSchedule(isEnabled: true, minuteOfDay: 21 * 60 + 45);

    expect(schedule.hour, 21);
    expect(schedule.minute, 45);
  });
}
