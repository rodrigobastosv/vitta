import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

abstract class ReminderFactory {
  static Reminder build({
    String id = 'reminder-1',
    String title = 'Pay the electricity bill',
    DateTime? dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = ReminderRecurrence.none,
    DateTime? completedAt,
  }) => Reminder(
    id: id,
    title: title,
    dueDate: dueDate ?? DateTime(2026, 7, 18),
    notes: notes,
    remindAt: remindAt,
    recurrence: recurrence,
    completedAt: completedAt,
  );
}
