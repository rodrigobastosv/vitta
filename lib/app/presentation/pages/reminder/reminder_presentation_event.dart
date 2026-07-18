sealed class ReminderPresentationEvent {}

class ReminderShowLoading implements ReminderPresentationEvent {}

class ReminderHideLoading implements ReminderPresentationEvent {}

class ReminderError implements ReminderPresentationEvent {
  const ReminderError({required this.message});

  final String message;
}
