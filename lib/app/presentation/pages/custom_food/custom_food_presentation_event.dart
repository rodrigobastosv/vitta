import 'dart:typed_data';

import 'package:vitta/app/domain/diet/entities/food.dart';

sealed class CustomFoodPresentationEvent {}

class CustomFoodShowLoading implements CustomFoodPresentationEvent {}

class CustomFoodHideLoading implements CustomFoodPresentationEvent {}

// The nutrition-label scan shows the scanning overlay (over the label photo)
// rather than the generic spinner - the same payoff as the meal scan.
class CustomFoodScanning implements CustomFoodPresentationEvent {
  const CustomFoodScanning({this.imageBytes});

  final Uint8List? imageBytes;
}

class CustomFoodIncomplete implements CustomFoodPresentationEvent {}

class CustomFoodScanFoundNothing implements CustomFoodPresentationEvent {}

class CustomFoodReady implements CustomFoodPresentationEvent {
  const CustomFoodReady({required this.food});

  final Food food;
}

// The Edge Function refused the scan (see PremiumRequiredError): the local lock
// was stale, so the page opens the paywall instead of showing a failure.
class CustomFoodPremiumRequired implements CustomFoodPresentationEvent {}

class CustomFoodError implements CustomFoodPresentationEvent {
  const CustomFoodError({required this.message});

  final String message;
}
