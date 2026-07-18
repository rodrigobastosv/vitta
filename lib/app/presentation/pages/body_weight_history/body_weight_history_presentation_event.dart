sealed class BodyWeightHistoryPresentationEvent {}

class BodyWeightHistoryShowLoading implements BodyWeightHistoryPresentationEvent {}

class BodyWeightHistoryHideLoading implements BodyWeightHistoryPresentationEvent {}

class BodyWeightHistoryError implements BodyWeightHistoryPresentationEvent {
  const BodyWeightHistoryError({required this.message});

  final String message;
}
