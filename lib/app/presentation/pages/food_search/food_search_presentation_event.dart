import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

sealed class FoodSearchPresentationEvent {}

class FoodSearchShowLoading extends VTShowLoading implements FoodSearchPresentationEvent {
  const FoodSearchShowLoading();
}

class FoodSearchHideLoading extends VTHideLoading implements FoodSearchPresentationEvent {
  const FoodSearchHideLoading();
}
