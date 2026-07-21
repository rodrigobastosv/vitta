import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_mode.dart';

class AddFoodExtra {
  const AddFoodExtra({required this.loggedDate, this.initialMealType}) : mode = AddFoodMode.log, unitSystem = null;

  const AddFoodExtra.pickIngredient({required UnitSystem this.unitSystem}) : mode = AddFoodMode.pickIngredient, loggedDate = null, initialMealType = null;

  final AddFoodMode mode;
  final DateTime? loggedDate;
  final MealType? initialMealType;
  final UnitSystem? unitSystem;
}
