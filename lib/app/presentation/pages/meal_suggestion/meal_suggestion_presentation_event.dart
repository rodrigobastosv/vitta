import 'package:vitta/app/domain/diet/entities/meal_type.dart';

sealed class MealSuggestionPresentationEvent {}

class MealSuggestionShowLoading implements MealSuggestionPresentationEvent {}

class MealSuggestionHideLoading implements MealSuggestionPresentationEvent {}

// Asking for suggestions is the same multi-second model call the scans make, so
// it gets the same overlay rather than the generic spinner.
class MealSuggestionThinking implements MealSuggestionPresentationEvent {}

class MealSuggestionFoundNothing implements MealSuggestionPresentationEvent {}

class MealSuggestionIncomplete implements MealSuggestionPresentationEvent {}

class MealSuggestionLogged implements MealSuggestionPresentationEvent {
  const MealSuggestionLogged({required this.mealType, required this.itemCount});

  final MealType mealType;
  final int itemCount;
}

// The Edge Function refused the request (see PremiumRequiredError): the local
// lock was stale, so the page opens the paywall instead of showing a failure.
class MealSuggestionPremiumRequired implements MealSuggestionPresentationEvent {}

class MealSuggestionError implements MealSuggestionPresentationEvent {
  const MealSuggestionError({required this.message});

  final String message;
}
