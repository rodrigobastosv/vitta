import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';

class LogRemindersLocalDataSource {
  LogRemindersLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _enabledKey = 'logReminders.enabled';

  static String _trackerEnabledKey(LogReminderTracker tracker) => 'logReminders.${tracker.wireValue}.enabled';

  static String _trackerMinuteKey(LogReminderTracker tracker) => 'logReminders.${tracker.wireValue}.minuteOfDay';

  LogReminderSettings getLogReminderSettings() {
    final shipped = LogReminderSettings.shipped;
    return LogReminderSettings(
      isEnabled: _localStorageService.get<bool>(_enabledKey) ?? shipped.isEnabled,
      schedules: {
        for (final tracker in LogReminderTracker.values)
          tracker: LogReminderSchedule(
            isEnabled: _localStorageService.get<bool>(_trackerEnabledKey(tracker)) ?? shipped.scheduleFor(tracker).isEnabled,
            minuteOfDay: _localStorageService.get<int>(_trackerMinuteKey(tracker)) ?? shipped.scheduleFor(tracker).minuteOfDay,
          ),
      },
    );
  }

  Future<void> saveLogReminderSettings(LogReminderSettings settings) async {
    await _localStorageService.put(_enabledKey, settings.isEnabled);
    for (final tracker in LogReminderTracker.values) {
      final schedule = settings.scheduleFor(tracker);
      await _localStorageService.put(_trackerEnabledKey(tracker), schedule.isEnabled);
      await _localStorageService.put(_trackerMinuteKey(tracker), schedule.minuteOfDay);
    }
  }
}
