import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_completion.dart';

class CompleteReminderUseCase {
  CompleteReminderUseCase({required this._reminderRepository});

  final ReminderRepository _reminderRepository;

  Future<Result<VTError, ReminderCompletion>> call({required Reminder reminder, required bool completed}) =>
      _reminderRepository.completeReminder(reminder: reminder, completed: completed);
}
