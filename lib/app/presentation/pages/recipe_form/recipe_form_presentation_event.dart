import 'package:vitta/app/domain/diet/entities/recipe.dart';

sealed class RecipeFormPresentationEvent {}

class RecipeFormShowLoading implements RecipeFormPresentationEvent {}

class RecipeFormHideLoading implements RecipeFormPresentationEvent {}

class RecipeFormIncomplete implements RecipeFormPresentationEvent {}

class RecipeCreated implements RecipeFormPresentationEvent {
  const RecipeCreated({required this.recipe});

  final Recipe recipe;
}

class RecipeFormError implements RecipeFormPresentationEvent {
  const RecipeFormError({required this.message});

  final String message;
}
