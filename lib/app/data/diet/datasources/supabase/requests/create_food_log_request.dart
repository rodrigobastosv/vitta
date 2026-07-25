import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class CreateFoodLogRequest {
  CreateFoodLogRequest({
    required this.userId,
    required this.foodId,
    required this.loggedDate,
    required this.mealType,
    required this.quantity,
  });

  final String userId;
  final String foodId;
  final DateTime loggedDate;
  final MealType mealType;
  final LoggedQuantity quantity;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'food_id': foodId,
    'logged_date': loggedDate.toIso8601String().split('T').first,
    'meal_type': mealType.wireValue,
    'quantity_grams': quantity.grams,
    'quantity_units': quantity.units,
    'quantity_ml': quantity.milliliters,
  };
}
