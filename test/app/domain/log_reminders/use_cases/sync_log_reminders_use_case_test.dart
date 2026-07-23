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
  LogReminderSettings buildSettings({bool isEnabled = true, bool isDietEnabled = true, int dietMinuteOfDay = 20 * 60}) => LogReminderSettings(
    isEnabled: isEnabled,
    schedules: {
      for (final tracker in LogReminderTracker.values)
        tracker: LogReminderSchedule(
          isEnabled: tracker != LogReminderTracker.diet || isDietEnabled,
          minuteOfDay: tracker == LogReminderTracker.diet ? dietMinuteOfDay : tracker.defaultMinuteOfDay,
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
      ),
    ).thenAnswer((_) async {});
    return (logReminders: logRemindersRepository, settings: settingsRepository, notifications: notificationService);
  }

  test('a tracker with nothing logged is scheduled for its time today', () async {
    final dependencies = buildDependencies(buildSettings());
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(loggedByTracker: {LogReminderTracker.diet: false}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.diet.notificationId,
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 23, 20),
      ),
    ).called(1);
  });

  test('a tracker already logged today is moved to tomorrow instead of firing', () async {
    final dependencies = buildDependencies(buildSettings());
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(loggedByTracker: {LogReminderTracker.diet: true}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.diet.notificationId,
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: DateTime(2026, 7, 24, 20),
      ),
    ).called(1);
  });

  test('a tracker turned off is cancelled rather than scheduled', () async {
    final dependencies = buildDependencies(buildSettings(isDietEnabled: false));
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(loggedByTracker: {LogReminderTracker.diet: false}, now: DateTime(2026, 7, 23, 12));

    verify(() => dependencies.notifications.cancel(LogReminderTracker.diet.notificationId)).called(1);
    verifyNever(
      () => dependencies.notifications.scheduleReminder(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
      ),
    );
  });

  test('the master switch being off cancels every tracker it is asked about', () async {
    final dependencies = buildDependencies(buildSettings(isEnabled: false));
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(
      loggedByTracker: {LogReminderTracker.diet: false, LogReminderTracker.water: false, LogReminderTracker.sleep: true},
      now: DateTime(2026, 7, 23, 12),
    );

    for (final tracker in LogReminderTracker.values) {
      verify(() => dependencies.notifications.cancel(tracker.notificationId)).called(1);
    }
  });

  test('a tracker left out of the request is neither scheduled nor cancelled', () async {
    final dependencies = buildDependencies(buildSettings());
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(loggedByTracker: {LogReminderTracker.diet: false}, now: DateTime(2026, 7, 23, 12));

    verifyNever(() => dependencies.notifications.cancel(LogReminderTracker.water.notificationId));
    verifyNever(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationId,
        title: any(named: 'title'),
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
      ),
    );
  });

  test('the notification text follows the saved locale', () async {
    final dependencies = buildDependencies(buildSettings());
    when(dependencies.settings.getSettings).thenReturn(const AppSettings(locale: Locale('pt')));
    final useCase = SyncLogRemindersUseCase(
      logRemindersRepository: dependencies.logReminders,
      settingsRepository: dependencies.settings,
      notificationService: dependencies.notifications,
    );

    await useCase(loggedByTracker: {LogReminderTracker.water: false}, now: DateTime(2026, 7, 23, 12));

    verify(
      () => dependencies.notifications.scheduleReminder(
        id: LogReminderTracker.water.notificationId,
        title: 'Hora da água',
        body: any(named: 'body'),
        dateTime: any(named: 'dateTime'),
      ),
    ).called(1);
  });

  test('every tracker owns a distinct notification slot', () {
    expect(LogReminderTracker.values.map((tracker) => tracker.notificationId).toSet().length, LogReminderTracker.values.length);
  });
}
