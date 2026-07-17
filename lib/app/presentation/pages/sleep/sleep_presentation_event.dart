sealed class SleepPresentationEvent {}

class SleepShowLoading implements SleepPresentationEvent {}

class SleepHideLoading implements SleepPresentationEvent {}

class SleepError implements SleepPresentationEvent {
  const SleepError({required this.message});

  final String message;
}

class SleepImported implements SleepPresentationEvent {
  const SleepImported({required this.count});

  final int count;
}

class SleepHealthUnavailable implements SleepPresentationEvent {}

class SleepHealthPermissionDenied implements SleepPresentationEvent {}
