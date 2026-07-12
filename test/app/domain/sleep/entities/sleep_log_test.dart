import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

import '../../../../factories/entities/sleep_log_factory.dart';

void main() {
  test('duration is the difference between wake time and bed time', () {
    final sleepLog = SleepLogFactory.build(bedTime: DateTime(2026, 7, 10, 22, 30), wakeTime: DateTime(2026, 7, 11, 6, 45));

    expect(sleepLog.duration, const Duration(hours: 8, minutes: 15));
  });

  test('fromMap parses a Supabase sleep_logs row', () {
    final sleepLog = SleepLog.fromMap(const {
      'id': 'sleep-1',
      'logged_date': '2026-07-11',
      'bed_time': '2026-07-10T22:30:00.000Z',
      'wake_time': '2026-07-11T06:45:00.000Z',
      'quality_rating': 4,
    });

    expect(sleepLog.id, 'sleep-1');
    expect(sleepLog.loggedDate, DateTime(2026, 7, 11));
    expect(sleepLog.bedTime, DateTime.parse('2026-07-10T22:30:00.000Z').toLocal());
    expect(sleepLog.wakeTime, DateTime.parse('2026-07-11T06:45:00.000Z').toLocal());
    expect(sleepLog.qualityRating, 4);
  });

  test('fromMap handles a null quality rating', () {
    final sleepLog = SleepLog.fromMap(const {
      'id': 'sleep-1',
      'logged_date': '2026-07-11',
      'bed_time': '2026-07-10T22:30:00.000Z',
      'wake_time': '2026-07-11T06:45:00.000Z',
      'quality_rating': null,
    });

    expect(sleepLog.qualityRating, isNull);
  });
}
