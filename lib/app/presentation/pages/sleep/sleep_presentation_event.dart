sealed class SleepPresentationEvent {}

class SleepShowLoading implements SleepPresentationEvent {}

class SleepHideLoading implements SleepPresentationEvent {}

class SleepError implements SleepPresentationEvent {
  const SleepError({required this.message});

  final String message;
}
