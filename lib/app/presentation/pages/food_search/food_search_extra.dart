import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class FoodSearchExtra {
  const FoodSearchExtra({required this.loggedDate, this.initialMealType});

  final DateTime loggedDate;
  final MealType? initialMealType;
}
