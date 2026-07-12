import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

sealed class WaterPresentationEvent {}

class WaterShowLoading extends VTShowLoading implements WaterPresentationEvent {
  const WaterShowLoading();
}

class WaterHideLoading extends VTHideLoading implements WaterPresentationEvent {
  const WaterHideLoading();
}
