import 'package:vitta/app/domain/diet/entities/food.dart';

sealed class CustomFoodPresentationEvent {}

class CustomFoodShowLoading implements CustomFoodPresentationEvent {}

class CustomFoodHideLoading implements CustomFoodPresentationEvent {}

class CustomFoodIncomplete implements CustomFoodPresentationEvent {}

class CustomFoodScanFoundNothing implements CustomFoodPresentationEvent {}

class CustomFoodReady implements CustomFoodPresentationEvent {
  const CustomFoodReady({required this.food});

  final Food food;
}

class CustomFoodError implements CustomFoodPresentationEvent {
  const CustomFoodError({required this.message});

  final String message;
}
