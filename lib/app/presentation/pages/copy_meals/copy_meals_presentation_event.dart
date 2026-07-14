sealed class CopyMealsPresentationEvent {}

class CopyMealsShowLoading implements CopyMealsPresentationEvent {}

class CopyMealsHideLoading implements CopyMealsPresentationEvent {}

class CopyMealsError implements CopyMealsPresentationEvent {
  const CopyMealsError({required this.message});

  final String message;
}

class MealsCopied implements CopyMealsPresentationEvent {
  const MealsCopied({required this.mealCount});

  final int mealCount;
}
