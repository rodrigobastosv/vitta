import 'package:flutter_test/flutter_test.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';

void main() {
  test('scales macros by quantity relative to 100g', () {
    final entry = FoodLogEntryFactory.build(
      food: FoodFactory.build(caloriesPer100g: 200, proteinPer100g: 20, carbsPer100g: 10, fatPer100g: 5),
      log: FoodLogFactory.build(quantityGrams: 150),
    );

    expect(entry.calories, 300);
    expect(entry.protein, 30);
    expect(entry.carbs, 15);
    expect(entry.fat, 7.5);
  });
}
