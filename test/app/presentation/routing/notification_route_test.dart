import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/notification_route.dart';

void main() {
  test('every meal nudge opens the diet page', () {
    for (final tracker in [LogReminderTracker.breakfast, LogReminderTracker.lunch, LogReminderTracker.dinner]) {
      expect(notificationRouteFor(tracker.notificationPayload), AppRoute.diet);
    }
  });

  test('the water and sleep nudges open their own trackers', () {
    expect(notificationRouteFor(LogReminderTracker.water.notificationPayload), AppRoute.water);
    expect(notificationRouteFor(LogReminderTracker.sleep.notificationPayload), AppRoute.sleep);
  });

  test("a user's own reminder opens the reminders page", () {
    expect(notificationRouteFor(reminderNotificationPayload), AppRoute.reminders);
  });

  test('a payload nothing claims lands nowhere rather than guessing', () {
    expect(notificationRouteFor(null), isNull);
    expect(notificationRouteFor('log_reminder:workout'), isNull);
    expect(notificationRouteFor('something else'), isNull);
  });
}
