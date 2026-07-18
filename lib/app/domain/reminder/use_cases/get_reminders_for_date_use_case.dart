import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class GetRemindersForDateUseCase {
  GetRemindersForDateUseCase({required this._reminderRepository});

  final ReminderRepository _reminderRepository;

  Future<Result<VTError, List<Reminder>>> call({required DateTime date}) => _reminderRepository.getRemindersForDate(date: date);
}
