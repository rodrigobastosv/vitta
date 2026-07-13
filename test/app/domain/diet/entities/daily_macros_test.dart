import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

void main() {
  test('sums macros across all entries', () {
    final dailyMacros = DailyMacros(
      entries: [
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 5, fatPer100g: 2, fiberPer100g: 3),
          log: FoodLogFactory.build(),
        ),
        FoodLogEntryFactory.build(
          food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 20, carbsPer100g: 10, fatPer100g: 4, fiberPer100g: 6),
          log: FoodLogFactory.build(quantityGrams: 50),
        ),
      ],
    );

    expect(dailyMacros.totalCalories, 200);
    expect(dailyMacros.totalProtein, 20);
    expect(dailyMacros.totalCarbs, 10);
    expect(dailyMacros.totalFat, 4);
    expect(dailyMacros.totalFiber, 6);
  });

  test('totals are zero with no entries', () {
    const dailyMacros = DailyMacros(entries: []);

    expect(dailyMacros.totalCalories, 0);
    expect(dailyMacros.totalProtein, 0);
    expect(dailyMacros.totalCarbs, 0);
    expect(dailyMacros.totalFat, 0);
    expect(dailyMacros.totalFiber, 0);
  });
}
