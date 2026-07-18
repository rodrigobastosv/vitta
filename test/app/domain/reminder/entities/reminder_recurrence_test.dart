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
  });

  group('fromWireValue', () {
    test('maps known values', () {
      expect(ReminderRecurrence.fromWireValue('daily'), ReminderRecurrence.daily);
      expect(ReminderRecurrence.fromWireValue('weekly'), ReminderRecurrence.weekly);
      expect(ReminderRecurrence.fromWireValue('monthly'), ReminderRecurrence.monthly);
    });

    test('maps null and unknown to none', () {
      expect(ReminderRecurrence.fromWireValue(null), ReminderRecurrence.none);
      expect(ReminderRecurrence.fromWireValue('yearly'), ReminderRecurrence.none);
    });
  });
}
