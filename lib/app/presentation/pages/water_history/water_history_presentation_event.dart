sealed class WaterHistoryPresentationEvent {}

class WaterHistoryShowLoading implements WaterHistoryPresentationEvent {}

class WaterHistoryHideLoading implements WaterHistoryPresentationEvent {}

class WaterHistoryError implements WaterHistoryPresentationEvent {
  const WaterHistoryError({required this.message});

  final String message;
}
