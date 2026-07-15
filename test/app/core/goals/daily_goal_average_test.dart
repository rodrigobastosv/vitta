import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/goals/daily_goal_average.dart';

void main() {
  test('no values at all means no data, not an average of zero', () {
    final average = DailyGoalAverage.fromValues(const []);

    expect(average.hasData, isFalse);
    expect(average.loggedDayCount, 0);
    expect(average.average, 0);
  });

  test('averages only the values it was given', () {
    final average = DailyGoalAverage.fromValues(const [2000, 1000, 3000]);

    expect(average.hasData, isTrue);
    expect(average.loggedDayCount, 3);
    expect(average.average, 2000);
  });

  test('a single value averages to itself', () {
    final average = DailyGoalAverage.fromValues(const [1500]);

    expect(average.loggedDayCount, 1);
    expect(average.average, 1500);
  });
}
