import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';

SleepLog buildLog({required int hours, int? qualityRating, String id = 'sleep-1'}) => SleepLog(
  id: id,
  loggedDate: DateTime(2026, 7, 10),
  bedTime: DateTime(2026, 7, 10, 23),
  wakeTime: DateTime(2026, 7, 10, 23).add(Duration(hours: hours)),
  qualityRating: qualityRating,
);

void main() {
  test('a single night is its own duration', () {
    const sleep = DailySleep(entries: []);
    expect(sleep.totalHours, 0);

    final night = DailySleep(entries: [buildLog(hours: 8)]);
    expect(night.totalHours, 8);
  });

  test('a nap on the same date adds to the night rather than replacing it', () {
    final day = DailySleep(
      entries: [
        buildLog(hours: 7),
        buildLog(hours: 1, id: 'nap'),
      ],
    );

    expect(day.totalHours, 8);
  });

  test('half hours survive the conversion', () {
    final night = DailySleep(
      entries: [SleepLog(id: 'a', loggedDate: DateTime(2026, 7, 10), bedTime: DateTime(2026, 7, 10, 23), wakeTime: DateTime(2026, 7, 11, 6, 30))],
    );

    expect(night.totalHours, 7.5);
  });

  test('an unrated night has no quality at all, rather than a zero', () {
    final night = DailySleep(entries: [buildLog(hours: 8)]);

    expect(night.averageQuality, isNull);
  });

  test('quality averages only the nights that were rated', () {
    final day = DailySleep(
      entries: [
        buildLog(hours: 4, qualityRating: 5),
        buildLog(hours: 4, id: 'b'),
        buildLog(hours: 1, id: 'c', qualityRating: 3),
      ],
    );

    expect(day.averageQuality, 4);
  });
}
