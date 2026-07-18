import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

class CreateReminderRequest {
  CreateReminderRequest({
    required this.userId,
    required this.title,
    required this.dueDate,
    this.notes,
    this.remindAt,
    this.recurrence = .none,
  });

  final String userId;
  final String title;
  final DateTime dueDate;
  final String? notes;
  final DateTime? remindAt;
  final ReminderRecurrence recurrence;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'notes': notes,
    'due_date': dueDate.toIso8601String().split('T').first,
    'remind_at': remindAt?.toUtc().toIso8601String(),
    'recurrence': recurrence.wireValue,
  };
}
