import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

class Reminder extends Equatable {
  const Reminder({required this.id, required this.title, required this.dueDate, this.notes, this.remindAt, this.recurrence = .none, this.completedAt});

  factory Reminder.fromMap(Map<String, dynamic> row) => Reminder(
    id: row['id'] as String,
    title: row['title'] as String,
    notes: row['notes'] as String?,
    dueDate: DateTime.parse(row['due_date'] as String),
    remindAt: row['remind_at'] == null ? null : DateTime.parse(row['remind_at'] as String).toLocal(),
    recurrence: ReminderRecurrence.fromWireValue(row['recurrence'] as String?),
    completedAt: row['completed_at'] == null ? null : DateTime.parse(row['completed_at'] as String).toLocal(),
  );

  final String id;
  final String title;
  final String? notes;
  final DateTime dueDate;
  final DateTime? remindAt;
  final ReminderRecurrence recurrence;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  bool get isRecurring => recurrence != .none;

  // Past its deadline and still open. The deadline is the reminder time when set,
  // otherwise the end of the due day, so an all-day reminder only reads as overdue
  // once the day is fully gone.
  bool isOverdue([DateTime? now]) {
    if (isCompleted) {
      return false;
    }
    final deadline = remindAt ?? DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59);
    return deadline.isBefore(now ?? DateTime.now());
  }

  // flutter_local_notifications keys schedules by int; derive a stable, non-negative
  // one from the row id so scheduling and cancelling always target the same slot.
  int get notificationId => id.hashCode & 0x7fffffff;

  Reminder toggledCompletion({required bool completed}) => Reminder(
    id: id,
    title: title,
    dueDate: dueDate,
    notes: notes,
    remindAt: remindAt,
    recurrence: recurrence,
    completedAt: completed ? DateTime.now() : null,
  );

  // The due date and reminder for the following occurrence of a recurring reminder,
  // shifting the reminder by the same span so its time-of-day is preserved.
  ({DateTime dueDate, DateTime? remindAt}) nextOccurrenceSchedule() {
    final nextDue = recurrence.nextDate(dueDate);
    final shift = nextDue.difference(dueDate);
    return (dueDate: nextDue, remindAt: remindAt?.add(shift));
  }

  @override
  List<Object?> get props => [id, title, notes, dueDate, remindAt, recurrence, completedAt];
}
