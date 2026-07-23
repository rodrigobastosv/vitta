import 'package:vitta/app/core/localization/app_localizations_lookup.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/data/log_reminders/log_reminders_repository.dart';
import 'package:vitta/app/data/settings/settings_repository.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';

class SyncLogRemindersUseCase {
  SyncLogRemindersUseCase({required this._logRemindersRepository, required this._settingsRepository, required this._notificationService});

  final LogRemindersRepository _logRemindersRepository;
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  Future<void> call({required Map<LogReminderTracker, bool> loggedByTracker, DateTime? now}) async {
    final settings = _logRemindersRepository.getLogReminderSettings();
    final moment = now ?? DateTime.now();
    final l10n = localizationsFor(_settingsRepository.getSettings().locale);
    for (final entry in loggedByTracker.entries) {
      final tracker = entry.key;
      if (!settings.isActiveFor(tracker)) {
        await _notificationService.cancel(tracker.notificationId);
        continue;
      }
      await _notificationService.scheduleReminder(
        id: tracker.notificationId,
        title: tracker.getTitle(l10n),
        body: tracker.getBody(l10n),
        dateTime: settings.scheduleFor(tracker).nextOccurrence(now: moment, isLoggedToday: entry.value),
      );
    }
  }
}
