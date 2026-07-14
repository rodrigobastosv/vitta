import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class UpdateFoodLogRequest {
  UpdateFoodLogRequest({required this.mealType, required this.quantityGrams});

  final MealType mealType;
  final double quantityGrams;

  Map<String, dynamic> toJson() => {'meal_type': mealType.wireValue, 'quantity_grams': quantityGrams};
}
