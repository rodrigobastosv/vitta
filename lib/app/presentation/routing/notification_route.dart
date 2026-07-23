import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

/// Where a tapped notification lands. The payload vocabulary belongs to
/// whoever scheduled the notification (a `LogReminderTracker`, or the plain
/// `reminderNotificationPayload` a user's own reminder carries), and mapping it
/// onto a route stays here so nothing below `presentation/` knows about
/// `AppRoute`.
const reminderNotificationPayload = 'reminder';

AppRoute? notificationRouteFor(String? payload) {
  if (payload == reminderNotificationPayload) {
    return .reminders;
  }
  return switch (LogReminderTracker.fromNotificationPayload(payload)) {
    .breakfast || .lunch || .dinner => AppRoute.diet,
    .water => AppRoute.water,
    .sleep => AppRoute.sleep,
    null => null,
  };
}
