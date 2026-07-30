import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';

Set<DateTime> _daysBefore(DateTime today, List<int> offsets) => {for (final offset in offsets) DateTime(today.year, today.month, today.day - offset)};

void main() {
  final today = DateTime(2026, 7, 29);

  test('a diary with nothing in it has no streak', () {
    final streak = LoggingStreak.from(loggedDays: const {}, today: today);

    expect(streak.days, 0);
    expect(streak.isActive, isFalse);
  });

  test('consecutive logged days count back from today', () {
    final streak = LoggingStreak.from(loggedDays: _daysBefore(today, [0, 1, 2]), today: today);

    expect(streak.days, 3);
    expect(streak.isActive, isTrue);
  });

  // The grace rule, both ways round: an unlogged today is someone who has not
  // eaten yet, so the streak has to survive it - but an unlogged yesterday means
  // a day was genuinely missed and it must not.
  test('a day with nothing logged yet keeps the streak, counting from yesterday', () {
    final streak = LoggingStreak.from(loggedDays: _daysBefore(today, [1, 2, 3]), today: today);

    expect(streak.days, 3);
  });

  test('an unlogged yesterday ends the streak even when today is logged', () {
    final streak = LoggingStreak.from(loggedDays: _daysBefore(today, [0, 2, 3]), today: today);

    expect(streak.days, 1);
  });

  test('neither today nor yesterday logged is no streak at all', () {
    final streak = LoggingStreak.from(loggedDays: _daysBefore(today, [2, 3, 4]), today: today);

    expect(streak.days, 0);
  });

  test('a gap stops the count rather than being skipped over', () {
    final streak = LoggingStreak.from(loggedDays: _daysBefore(today, [0, 1, 3, 4, 5]), today: today);

    expect(streak.days, 2);
  });

  test('a streak counts across a month boundary', () {
    final firstOfAugust = DateTime(2026, 8);
    final streak = LoggingStreak.from(loggedDays: _daysBefore(firstOfAugust, [0, 1, 2]), today: firstOfAugust);

    expect(streak.days, 3);
  });

  test('the time of day a logged date carries is ignored', () {
    final streak = LoggingStreak.from(loggedDays: {DateTime(2026, 7, 29, 22, 30), DateTime(2026, 7, 28, 6)}, today: DateTime(2026, 7, 29, 9, 15));

    expect(streak.days, 2);
  });
}
