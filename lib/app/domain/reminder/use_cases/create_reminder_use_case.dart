import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

class CreateReminderUseCase {
  CreateReminderUseCase({required this._reminderRepository});

  final ReminderRepository _reminderRepository;

  Future<Result<VTError, Reminder>> call({
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) => _reminderRepository.createReminder(title: title, dueDate: dueDate, notes: notes, remindAt: remindAt, recurrence: recurrence);
}
