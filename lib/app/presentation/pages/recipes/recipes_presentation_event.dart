sealed class RecipesPresentationEvent {}

class RecipesShowLoading implements RecipesPresentationEvent {}

class RecipesHideLoading implements RecipesPresentationEvent {}

class RecipesError implements RecipesPresentationEvent {
  const RecipesError({required this.message});

  final String message;
}
