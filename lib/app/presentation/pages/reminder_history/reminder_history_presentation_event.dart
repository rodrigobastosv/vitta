sealed class ReminderHistoryPresentationEvent {}

class ReminderHistoryShowLoading implements ReminderHistoryPresentationEvent {}

class ReminderHistoryHideLoading implements ReminderHistoryPresentationEvent {}

class ReminderHistoryError implements ReminderHistoryPresentationEvent {
  const ReminderHistoryError({required this.message});

  final String message;
}
