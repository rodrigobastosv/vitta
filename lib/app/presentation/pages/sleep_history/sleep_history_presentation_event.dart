sealed class SleepHistoryPresentationEvent {}

class SleepHistoryShowLoading implements SleepHistoryPresentationEvent {}

class SleepHistoryHideLoading implements SleepHistoryPresentationEvent {}

class SleepHistoryError implements SleepHistoryPresentationEvent {
  const SleepHistoryError({required this.message});

  final String message;
}
