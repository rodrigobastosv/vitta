import 'package:vitta/app/data/log_reminders/log_reminders_repository.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';

class SaveLogReminderSettingsUseCase {
  SaveLogReminderSettingsUseCase({required this._logRemindersRepository});

  final LogRemindersRepository _logRemindersRepository;

  Future<void> call(LogReminderSettings settings) => _logRemindersRepository.saveLogReminderSettings(settings);
}
