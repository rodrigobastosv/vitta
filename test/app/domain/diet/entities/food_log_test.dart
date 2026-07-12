import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

void main() {
  test('fromMap parses a Supabase food_logs row', () {
    final foodLog = FoodLog.fromMap(const {
      'id': 'log-1',
      'food_id': 'food-1',
      'logged_date': '2026-07-11',
      'meal_type': 'lunch',
      'quantity_grams': 150,
    });

    expect(
      foodLog,
      FoodLog(id: 'log-1', foodId: 'food-1', loggedDate: DateTime(2026, 7, 11), mealType: MealType.lunch, quantityGrams: 150),
    );
  });
}
