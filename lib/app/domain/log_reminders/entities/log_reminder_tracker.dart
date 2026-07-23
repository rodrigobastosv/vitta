import 'package:vitta/l10n/arb/app_localizations.dart';

enum LogReminderTracker {
  diet('diet', 20 * 60),
  water('water', 15 * 60),
  sleep('sleep', 9 * 60);

  const LogReminderTracker(this.wireValue, this.defaultMinuteOfDay);

  static const _notificationIdBase = 910000;

  final String wireValue;
  final int defaultMinuteOfDay;

  int get notificationId => _notificationIdBase + index;

  String getTitle(AppLocalizations l10n) => switch (this) {
    .diet => l10n.logRemindersDietNotificationTitle,
    .water => l10n.logRemindersWaterNotificationTitle,
    .sleep => l10n.logRemindersSleepNotificationTitle,
  };

  String getBody(AppLocalizations l10n) => switch (this) {
    .diet => l10n.logRemindersDietNotificationBody,
    .water => l10n.logRemindersWaterNotificationBody,
    .sleep => l10n.logRemindersSleepNotificationBody,
  };

  static LogReminderTracker? fromWireValue(String? value) {
    for (final tracker in LogReminderTracker.values) {
      if (tracker.wireValue == value) {
        return tracker;
      }
    }
    return null;
  }
}
