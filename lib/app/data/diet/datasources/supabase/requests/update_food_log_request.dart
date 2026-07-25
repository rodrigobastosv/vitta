import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class UpdateFoodLogRequest {
  UpdateFoodLogRequest({required this.mealType, required this.quantity});

  final MealType mealType;
  final LoggedQuantity quantity;

  Map<String, dynamic> toJson() => {
    'meal_type': mealType.wireValue,
    'quantity_grams': quantity.grams,
    'quantity_units': quantity.units,
    'quantity_ml': quantity.milliliters,
  };
}
