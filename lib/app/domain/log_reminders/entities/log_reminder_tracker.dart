import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum LogReminderTracker {
  breakfast('breakfast', 10 * 60, mealType: .breakfast),
  lunch('lunch', 14 * 60, mealType: .lunch),
  dinner('dinner', 21 * 60, mealType: .dinner),
  water('water', 9 * 60, supportsInterval: true),
  sleep('sleep', 9 * 60);

  const LogReminderTracker(this.wireValue, this.defaultMinuteOfDay, {this.mealType, this.supportsInterval = false});

  static const _notificationIdBase = 910000;
  static const slotsPerTracker = 12;

  final String wireValue;
  final int defaultMinuteOfDay;
  final MealType? mealType;
  final bool supportsInterval;

  int notificationIdFor(int slot) => _notificationIdBase + index * slotsPerTracker + slot;

  String get notificationPayload => '$notificationPayloadPrefix$wireValue';

  static const notificationPayloadPrefix = 'log_reminder:';

  String getTitle(AppLocalizations l10n) => switch (this) {
    .breakfast => l10n.logRemindersBreakfastNotificationTitle,
    .lunch => l10n.logRemindersLunchNotificationTitle,
    .dinner => l10n.logRemindersDinnerNotificationTitle,
    .water => l10n.logRemindersWaterNotificationTitle,
    .sleep => l10n.logRemindersSleepNotificationTitle,
  };

  String getBody(AppLocalizations l10n) => switch (this) {
    .breakfast => l10n.logRemindersBreakfastNotificationBody,
    .lunch => l10n.logRemindersLunchNotificationBody,
    .dinner => l10n.logRemindersDinnerNotificationBody,
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

  static LogReminderTracker? fromNotificationPayload(String? payload) {
    if (payload == null || !payload.startsWith(notificationPayloadPrefix)) {
      return null;
    }
    return fromWireValue(payload.substring(notificationPayloadPrefix.length));
  }
}
