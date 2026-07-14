import 'package:vitta/app/domain/diet/entities/meal_type.dart';

sealed class FoodSearchPresentationEvent {}

class FoodSearchShowLoading implements FoodSearchPresentationEvent {}

class FoodSearchHideLoading implements FoodSearchPresentationEvent {}

class FoodLogged implements FoodSearchPresentationEvent {
  const FoodLogged({required this.foodName, required this.mealType});

  final String foodName;
  final MealType mealType;
}

class FoodSearchError implements FoodSearchPresentationEvent {
  const FoodSearchError({required this.message});

  final String message;
}
