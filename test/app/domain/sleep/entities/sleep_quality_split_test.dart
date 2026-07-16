import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/sleep/entities/daily_sleep.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_quality_split.dart';

DailySleep buildDay(List<int?> ratings) => DailySleep(
  entries: [
    for (final (index, rating) in ratings.indexed)
      SleepLog(
        id: 'log-$index',
        loggedDate: DateTime(2026, 7, 10),
        bedTime: DateTime(2026, 7, 10, 23),
        wakeTime: DateTime(2026, 7, 11, 7),
        qualityRating: rating,
      ),
  ],
);

void main() {
  test('no rated nights means no data, so the card can say so instead of drawing an empty bar', () {
    final split = SleepQualitySplit.fromDays([
      buildDay([null, null]),
    ]);

    expect(split.hasData, isFalse);
    expect(split.ratedNightCount, 0);
    expect(split.shareAt(3), 0);
  });

  test('unrated nights are left out of the count, rather than counting as bad', () {
    final split = SleepQualitySplit.fromDays([
      buildDay([5, null]),
      buildDay([5]),
    ]);

    expect(split.ratedNightCount, 2);
    expect(split.nightsAt(5), 2);
    expect(split.shareAt(5), 1);
  });

  test('shares are of the rated nights', () {
    final split = SleepQualitySplit.fromDays([
      buildDay([5, 3]),
      buildDay([3, 1]),
    ]);

    expect(split.ratedNightCount, 4);
    expect(split.shareAt(3), 0.5);
    expect(split.shareAt(5), 0.25);
    expect(split.nightsAt(2), 0);
  });
}
