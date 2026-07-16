import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class UpdateFoodLogRequest {
  UpdateFoodLogRequest({required this.mealType, required this.quantityGrams, this.quantityUnits});

  final MealType mealType;
  final double quantityGrams;
  final double? quantityUnits;

  Map<String, dynamic> toJson() => {
    'meal_type': mealType.wireValue,
    'quantity_grams': quantityGrams,
    'quantity_units': quantityUnits,
  };
}
