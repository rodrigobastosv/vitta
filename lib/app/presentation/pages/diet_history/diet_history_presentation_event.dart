sealed class DietHistoryPresentationEvent {}

class DietHistoryShowLoading implements DietHistoryPresentationEvent {}

class DietHistoryHideLoading implements DietHistoryPresentationEvent {}

class DietHistoryError implements DietHistoryPresentationEvent {
  const DietHistoryError({required this.message});

  final String message;
}
