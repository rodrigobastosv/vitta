import 'package:vitta/app/domain/diet/entities/meal_type.dart';

sealed class AddFoodPresentationEvent {}

class AddFoodShowLoading implements AddFoodPresentationEvent {}

class AddFoodHideLoading implements AddFoodPresentationEvent {}

class FoodLogged implements AddFoodPresentationEvent {
  const FoodLogged({required this.foodName, required this.mealType});

  final String foodName;
  final MealType mealType;
}

class MealLogged implements AddFoodPresentationEvent {
  const MealLogged({required this.mealType, required this.foodCount});

  final MealType mealType;
  final int foodCount;
}

class AddFoodError implements AddFoodPresentationEvent {
  const AddFoodError();
}
