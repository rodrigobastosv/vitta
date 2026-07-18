import 'package:vitta/app/domain/reminder/entities/reminder.dart';

// The outcome of completing a reminder: the updated row, plus the next occurrence a
// recurring reminder spawned (null when it isn't recurring or was un-completed).
class ReminderCompletion {
  const ReminderCompletion({required this.reminder, this.nextOccurrence});

  final Reminder reminder;
  final Reminder? nextOccurrence;
}
