import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

abstract class FoodLogFactory {
  static FoodLog build({
    String id = 'log-1',
    String foodId = 'food-1',
    DateTime? loggedDate,
    MealType mealType = MealType.breakfast,
    double quantityGrams = 100,
    double? quantityUnits,
  }) => FoodLog(
    id: id,
    foodId: foodId,
    loggedDate: loggedDate ?? DateTime(2026, 7, 11),
    mealType: mealType,
    quantityGrams: quantityGrams,
    quantityUnits: quantityUnits,
  );
}
