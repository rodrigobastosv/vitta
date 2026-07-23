import 'package:vitta/app/data/log_reminders/log_reminders_local_datasource.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';

class LogRemindersRepository {
  LogRemindersRepository({required this._logRemindersLocalDataSource});

  final LogRemindersLocalDataSource _logRemindersLocalDataSource;

  LogReminderSettings getLogReminderSettings() => _logRemindersLocalDataSource.getLogReminderSettings();

  Future<void> saveLogReminderSettings(LogReminderSettings settings) => _logRemindersLocalDataSource.saveLogReminderSettings(settings);
}
