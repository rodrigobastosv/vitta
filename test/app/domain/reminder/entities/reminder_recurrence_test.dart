import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

void main() {
  group('nextDate', () {
    test('none returns the same date', () {
      expect(ReminderRecurrence.none.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 7, 18));
    });

    test('daily adds one day', () {
      expect(ReminderRecurrence.daily.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 7, 19));
    });

    test('daily rolls over the month end', () {
      expect(ReminderRecurrence.daily.nextDate(DateTime(2026, 7, 31)), DateTime(2026, 8));
    });

    test('weekly adds seven days across a month boundary', () {
      expect(ReminderRecurrence.weekly.nextDate(DateTime(2026, 7, 28)), DateTime(2026, 8, 4));
    });

    test('monthly adds one month', () {
      expect(ReminderRecurrence.monthly.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 8, 18));
    });

    test('monthly clamps to the last day of a shorter month', () {
      expect(ReminderRecurrence.monthly.nextDate(DateTime(2026, 1, 31)), DateTime(2026, 2, 28));
    });

    test('monthly wraps December into the next January', () {
      expect(ReminderRecurrence.monthly.nextDate(DateTime(2026, 12, 15)), DateTime(2027, 1, 15));
    });

    test('weekdays adds one day within the working week', () {
      expect(ReminderRecurrence.weekdays.nextDate(DateTime(2026, 7, 15)), DateTime(2026, 7, 16));
    });

    test('weekdays skips the weekend from a Friday', () {
      expect(ReminderRecurrence.weekdays.nextDate(DateTime(2026, 7, 17)), DateTime(2026, 7, 20));
    });

    test('weekdays lands on Monday from a Saturday', () {
      expect(ReminderRecurrence.weekdays.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 7, 20));
    });

    test('firstDayOfMonth lands on the next month regardless of the day it starts from', () {
      expect(ReminderRecurrence.firstDayOfMonth.nextDate(DateTime(2026, 7)), DateTime(2026, 8));
      expect(ReminderRecurrence.firstDayOfMonth.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 8));
    });

    test('firstDayOfMonth wraps December into the next January', () {
      expect(ReminderRecurrence.firstDayOfMonth.nextDate(DateTime(2026, 12, 15)), DateTime(2027));
    });

    test('lastDayOfMonth lands on this month end when it has not passed yet', () {
      expect(ReminderRecurrence.lastDayOfMonth.nextDate(DateTime(2026, 7, 18)), DateTime(2026, 7, 31));
    });

    test('lastDayOfMonth moves to the next month end, keeping the real length of a short one', () {
      expect(ReminderRecurrence.lastDayOfMonth.nextDate(DateTime(2026, 1, 31)), DateTime(2026, 2, 28));
      expect(ReminderRecurrence.lastDayOfMonth.nextDate(DateTime(2026, 2, 28)), DateTime(2026, 3, 31));
    });

    test('lastDayOfMonth wraps December into the next January', () {
      expect(ReminderRecurrence.lastDayOfMonth.nextDate(DateTime(2026, 12, 31)), DateTime(2027, 1, 31));
    });

    test('yearly adds one year', () {
      expect(ReminderRecurrence.yearly.nextDate(DateTime(2026, 7, 18)), DateTime(2027, 7, 18));
    });

    test('yearly clamps a leap day onto the following February', () {
      expect(ReminderRecurrence.yearly.nextDate(DateTime(2028, 2, 29)), DateTime(2029, 2, 28));
    });
  });

  group('fromWireValue', () {
    test('maps known values', () {
      expect(ReminderRecurrence.fromWireValue('daily'), ReminderRecurrence.daily);
      expect(ReminderRecurrence.fromWireValue('weekdays'), ReminderRecurrence.weekdays);
      expect(ReminderRecurrence.fromWireValue('weekly'), ReminderRecurrence.weekly);
      expect(ReminderRecurrence.fromWireValue('monthly'), ReminderRecurrence.monthly);
      expect(ReminderRecurrence.fromWireValue('first_day_of_month'), ReminderRecurrence.firstDayOfMonth);
      expect(ReminderRecurrence.fromWireValue('last_day_of_month'), ReminderRecurrence.lastDayOfMonth);
      expect(ReminderRecurrence.fromWireValue('yearly'), ReminderRecurrence.yearly);
    });

    test('maps null and unknown to none', () {
      expect(ReminderRecurrence.fromWireValue(null), ReminderRecurrence.none);
      expect(ReminderRecurrence.fromWireValue('fortnightly'), ReminderRecurrence.none);
    });
  });
}
