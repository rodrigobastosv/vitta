import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/calorie_average.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

DailyMacros buildDayOf(double calories) => DailyMacros(
  entries: [
    FoodLogEntryFactory.build(
      food: FoodFactory.build(caloriesPer100g: calories),
      log: FoodLogFactory.build(),
    ),
  ],
);

void main() {
  test('averages only the days that actually have food logged', () {
    final average = CalorieAverage.fromLoggedDays([buildDayOf(1000), buildDayOf(2000)]);

    expect(average.loggedDayCount, 2);
    expect(average.averageCalories, 1500);
    expect(average.hasData, isTrue);
  });

  test('a day present but with no entries does not drag the average down', () {
    final average = CalorieAverage.fromLoggedDays([buildDayOf(2000), const DailyMacros(entries: [])]);

    expect(average.loggedDayCount, 1);
    expect(average.averageCalories, 2000);
  });

  test('has no data when nothing was logged', () {
    final average = CalorieAverage.fromLoggedDays(const [DailyMacros(entries: [])]);

    expect(average.hasData, isFalse);
    expect(average.averageCalories, 0);
  });

  test('has no data for an empty list', () {
    expect(CalorieAverage.fromLoggedDays(const []).hasData, isFalse);
  });
}
