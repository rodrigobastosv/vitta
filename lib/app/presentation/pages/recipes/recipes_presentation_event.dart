import 'package:vitta/app/domain/diet/entities/meal_type.dart';

sealed class RecipesPresentationEvent {}

class RecipesShowLoading implements RecipesPresentationEvent {}

class RecipesHideLoading implements RecipesPresentationEvent {}

class RecipesError implements RecipesPresentationEvent {
  const RecipesError({required this.message});

  final String message;
}

class RecipeLogged implements RecipesPresentationEvent {
  const RecipeLogged({required this.recipeName, required this.mealType});

  final String recipeName;
  final MealType mealType;
}
