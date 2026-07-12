sealed class WaterPresentationEvent {}

class WaterShowLoading implements WaterPresentationEvent {}

class WaterHideLoading implements WaterPresentationEvent {}

class WaterError implements WaterPresentationEvent {
  const WaterError({required this.message});

  final String message;
}
