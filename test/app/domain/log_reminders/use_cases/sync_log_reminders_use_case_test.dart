import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/domain/log_reminders/use_cases/sync_log_reminders_use_case.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

import '../../../../mocks/repositories_mocks.dart';
import '../../../../mocks/services_mocks.dart';

void main() {
  LogReminderSettings buildSettings({
    bool isEnabled = true,
    bool isDinnerEnabled = true,
    int dinnerMinuteOfDay = 21 * 60,
    int? waterIntervalHours,
    int waterMinuteOfDay = 9 * 60,
  }) => LogReminderSettings(
    isEnabled: isEnabled,
    schedules: {
      for (final tracker in LogReminderTracker.values)
        tracker: LogReminderSchedule(
          isEnabled: tracker != LogReminderTracker.dinner || isDinnerEnabled,
          minuteOfDay: switch (tracker) {
            .dinner => dinnerMinuteOfDay,
            .water => waterMinuteOfDay,
            _ => tracker.defaultMinuteOfDay,
          },
          intervalHours: tracker == LogReminderTracker.water ? waterIntervalHours : null,
        ),
    },
  );

  ({MockLogRemindersRepository logReminders, MockSettingsRepository settings, MockNotificationService notifications}) buildDependencies(
    LogReminderSettings settings,
  ) {
    final logRemindersRepository = MockLogRemindersRepository();
    when(logRemindersRepository.getLogReminderSettings).thenReturn(settings);
    final settingsRepository = MockSettingsRepository();
    when(settingsRepository.getSettings).thenReturn(const AppSettings());
    final notificationService = MockNotificationService();
    when(() => notificationService.cancel(any())).thenAnswer((_) async {});
    when(
      () => notificationService.scheduleReminder(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    return (logReminders: logRemindersRepository, settings: settingsRepository, notifications: notificationService);
  }

  SyncLogRemindersUseCase buildUseCase(
    ({MockLogRemindersRepository logReminders, MockSettingsRepository settings, MockNotificationService notifications}) dependencies,
  ) => SyncLogRemindersUseCase(
    logRemindersRepository: dependencies.logReminders,
    settingsRepository: dependencies.settings,
    notificationService: dependencies.notifications,
  );

  test('a tracker with nothing logged is scheduled for its time today', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.dinner: false}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.dinner.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 23, 21),
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('a tracker already logged today is moved to tomorrow instead of firing', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.dinner: true}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.dinner.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 24, 21),
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('each meal is judged on its own meal type', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(
      loggedByTracker: {LogReminderTracker.breakfast: true, LogReminderTracker.lunch: false},
      now: DateTime(2026, 7, 23, 8),
    );

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.breakfast.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 24, 10),
        payload: any(named: 'payload'),
      ),
    ).called(1);
    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.lunch.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 23, 14),
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('a repeating water schedule fills a slot per interval through the day', () async {
    final dependencies = buildDependencies(buildSettings(waterIntervalHours: 3));

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.water: false}, now: DateTime(2026, 7, 23, 10));

    for (final (slot, expected) in [DateTime(2026, 7, 23, 12), DateTime(2026, 7, 23, 15), DateTime(2026, 7, 23, 18), DateTime(2026, 7, 23, 21)].indexed) {
      verify(
        () => dependencies.notifications.scheduleReminder(
          id: LogReminderTracker.water.notificationIdFor(slot),
          title: any(named: 'title'),
          body: any(named: 'body'),
          dateTime: expected,
          payload: any(named: 'payload'),
        ),
      ).called(1);
    }
  });

  test('a repeating schedule keeps nudging on a day that already has a log', () async {
    final dependencies = buildDependencies(buildSettings(waterIntervalHours: 3));

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.water: true}, now: DateTime(2026, 7, 23, 10));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 23, 12),
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('a tracker turned off is cancelled rather than scheduled', () async {
    final dependencies = buildDependencies(buildSettings(isDinnerEnabled: false));

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.dinner: false}, now: DateTime(2026, 7, 23, 12));

    verify(() => dependencies.notifications.cancel(LogReminderTracker.dinner.notificationIdFor(0))).called(1);
    verifyNever(
      () => dependencies.notifications.scheduleReminder(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
        payload: any(named: 'payload'),
      ),
    );
  });

  test('the slots a shortened schedule no longer needs are cancelled', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.water: false}, now: DateTime(2026, 7, 23, 12));

    for (var slot = 1; slot < LogReminderTracker.slotsPerTracker; slot++) {
      verify(() => dependencies.notifications.cancel(LogReminderTracker.water.notificationIdFor(slot))).called(1);
    }
  });

  test('the master switch being off cancels every tracker it is asked about', () async {
    final dependencies = buildDependencies(buildSettings(isEnabled: false));

    await buildUseCase(dependencies)(
      loggedByTracker: {LogReminderTracker.lunch: false, LogReminderTracker.water: false, LogReminderTracker.sleep: true},
      now: DateTime(2026, 7, 23, 12),
    );

    for (final tracker in [LogReminderTracker.lunch, LogReminderTracker.water, LogReminderTracker.sleep]) {
      verify(() => dependencies.notifications.cancel(tracker.notificationIdFor(0))).called(1);
    }
  });

  test('a tracker left out of the request is neither scheduled nor cancelled', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.lunch: false}, now: DateTime(2026, 7, 23, 12));

    verifyNever(() => dependencies.notifications.cancel(LogReminderTracker.water.notificationIdFor(0)));
    verifyNever(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
        payload: any(named: 'payload'),
      ),
    );
  });

  test('the notification carries the payload its tracker is opened by', () async {
    final dependencies = buildDependencies(buildSettings());

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.water: false}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationIdFor(0),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
        payload: LogReminderTracker.water.notificationPayload,
      ),
    ).called(1);
  });

  test('the notification text follows the saved locale', () async {
    final dependencies = buildDependencies(buildSettings());
    when(dependencies.settings.getSettings).thenReturn(const AppSettings(locale: Locale('pt')));

    await buildUseCase(dependencies)(loggedByTracker: {LogReminderTracker.water: false}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationIdFor(0),
        title: 'Hora da água',
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
        payload: any(named: 'payload'),
      ),
    ).called(1);
  });

  test('no two trackers can claim the same notification slot', () {
    final ids = {
      for (final tracker in LogReminderTracker.values)
        for (var slot = 0; slot < LogReminderTracker.slotsPerTracker; slot++) tracker.notificationIdFor(slot),
    };

    expect(ids.length, LogReminderTracker.values.length * LogReminderTracker.slotsPerTracker);
  });
}
