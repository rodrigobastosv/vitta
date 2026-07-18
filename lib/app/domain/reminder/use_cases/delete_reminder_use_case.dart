import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/reminder_repository.dart';

class DeleteReminderUseCase {
  DeleteReminderUseCase({required this._reminderRepository});

  final ReminderRepository _reminderRepository;

  Future<Result<VTError, void>> call({required String reminderId}) => _reminderRepository.deleteReminder(reminderId: reminderId);
}
