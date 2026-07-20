import 'package:vitta/app/domain/diet/entities/meal_type.dart';

sealed class MealScanPresentationEvent {}

class MealScanShowLoading implements MealScanPresentationEvent {}

class MealScanHideLoading implements MealScanPresentationEvent {}

class MealScanFoundNothing implements MealScanPresentationEvent {}

class MealScanIncomplete implements MealScanPresentationEvent {}

class MealScanLogged implements MealScanPresentationEvent {
  const MealScanLogged({required this.mealType, required this.itemCount});

  final MealType mealType;
  final int itemCount;
}

// The Edge Function refused the scan (see PremiumRequiredError): the local lock
// was stale, so the page opens the paywall instead of showing a failure.
class MealScanPremiumRequired implements MealScanPresentationEvent {}

class MealScanError implements MealScanPresentationEvent {
  const MealScanError({required this.message});

  final String message;
}
