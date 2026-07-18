import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class GetRemindersInRangeUseCase {
  GetRemindersInRangeUseCase({required this._reminderRepository});

  final ReminderRepository _reminderRepository;

  Future<Result<VTError, Map<DateTime, List<Reminder>>>> call({required DateTime from, required DateTime to}) =>
      _reminderRepository.getRemindersInRange(from: from, to: to);
}
