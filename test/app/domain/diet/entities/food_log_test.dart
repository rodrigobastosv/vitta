import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';

void main() {
  test('fromMap parses a Supabase food_logs row', () {
    final foodLog = FoodLog.fromMap(const {'id': 'log-1', 'food_id': 'food-1', 'logged_date': '2026-07-11', 'meal_type': 'lunch', 'quantity_grams': 150});

    expect(foodLog, FoodLog(id: 'log-1', foodId: 'food-1', loggedDate: DateTime(2026, 7, 11), mealType: .lunch, quantityGrams: 150));
  });

  test('fromMap parses a log the user counted rather than weighed', () {
    final foodLog = FoodLog.fromMap(const {
      'id': 'log-1',
      'food_id': 'food-1',
      'logged_date': '2026-07-11',
      'meal_type': 'breakfast',
      'quantity_grams': 100,
      'quantity_units': 2,
    });

    expect(foodLog.quantityUnits, 2);
    expect(foodLog.isLoggedInUnits, isTrue);
  });

  test('fromMap leaves a weighed log with no unit count', () {
    final foodLog = FoodLog.fromMap(const {
      'id': 'log-1',
      'food_id': 'food-1',
      'logged_date': '2026-07-11',
      'meal_type': 'breakfast',
      'quantity_grams': 100,
      'quantity_units': null,
    });

    expect(foodLog.quantityUnits, isNull);
    expect(foodLog.isLoggedInUnits, isFalse);
  });
}
