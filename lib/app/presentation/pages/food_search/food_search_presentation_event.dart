sealed class FoodSearchPresentationEvent {}

class FoodSearchShowLoading implements FoodSearchPresentationEvent {}

class FoodSearchHideLoading implements FoodSearchPresentationEvent {}

class FoodSearchError implements FoodSearchPresentationEvent {
  const FoodSearchError({required this.message});

  final String message;
}
