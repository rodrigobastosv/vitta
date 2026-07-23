import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_cubit.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_presentation_event.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  MockGetLogReminderSettingsUseCase buildSettingsReader(LogReminderSettings settings) {
    final getLogReminderSettingsUseCase = MockGetLogReminderSettingsUseCase();
    when(getLogReminderSettingsUseCase.call).thenReturn(settings);
    return getLogReminderSettingsUseCase;
  }

  MockSaveLogReminderSettingsUseCase buildSettingsWriter() {
    final saveLogReminderSettingsUseCase = MockSaveLogReminderSettingsUseCase();
    when(() => saveLogReminderSettingsUseCase(any())).thenAnswer((_) async {});
    return saveLogReminderSettingsUseCase;
  }

  MockSyncLogRemindersUseCase buildSync() {
    final syncLogRemindersUseCase = MockSyncLogRemindersUseCase();
    when(() => syncLogRemindersUseCase(loggedByTracker: any(named: 'loggedByTracker'))).thenAnswer((_) async {});
    return syncLogRemindersUseCase;
  }

  MockNotificationService buildPermissiveNotifications() {
    final notificationService = MockNotificationService();
    when(notificationService.requestPermission).thenAnswer((_) async => true);
    return notificationService;
  }

  setUpAll(() => registerFallbackValue(LogReminderSettings.shipped));

  blocTest<LogRemindersCubit, LogReminderSettings>(
    'turning the master switch on enables reminders',
    build: () => CubitsFactories.buildLogRemindersCubit(
      getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped),
      saveLogReminderSettingsUseCase: buildSettingsWriter(),
      syncLogRemindersUseCase: buildSync(),
      notificationService: buildPermissiveNotifications(),
    ),
    act: (cubit) => cubit.setEnabled(isEnabled: true),
    expect: () => [isA<LogReminderSettings>().having((settings) => settings.isEnabled, 'isEnabled', isTrue)],
  );

  blocTest<LogRemindersCubit, LogReminderSettings>(
    'a refused notification permission leaves reminders off',
    build: () {
      final notificationService = MockNotificationService();
      when(notificationService.requestPermission).thenAnswer((_) async => false);
      return CubitsFactories.buildLogRemindersCubit(
        getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped),
        saveLogReminderSettingsUseCase: buildSettingsWriter(),
        syncLogRemindersUseCase: buildSync(),
        notificationService: notificationService,
      );
    },
    act: (cubit) => cubit.setEnabled(isEnabled: true),
    expect: () => <LogReminderSettings>[],
  );

  blocPresentationTest<LogRemindersCubit, LogReminderSettings, LogRemindersPresentationEvent>(
    'a refused permission is reported to the page',
    build: () {
      final notificationService = MockNotificationService();
      when(notificationService.requestPermission).thenAnswer((_) async => false);
      return CubitsFactories.buildLogRemindersCubit(
        getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped),
        saveLogReminderSettingsUseCase: buildSettingsWriter(),
        syncLogRemindersUseCase: buildSync(),
        notificationService: notificationService,
      );
    },
    act: (cubit) => cubit.setEnabled(isEnabled: true),
    expectPresentation: () => [isA<LogRemindersPermissionDenied>()],
  );

  blocTest<LogRemindersCubit, LogReminderSettings>(
    'turning the master switch off asks for no permission',
    build: () {
      final notificationService = MockNotificationService();
      return CubitsFactories.buildLogRemindersCubit(
        getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped.withEnabled(isEnabled: true)),
        saveLogReminderSettingsUseCase: buildSettingsWriter(),
        syncLogRemindersUseCase: buildSync(),
        notificationService: notificationService,
      );
    },
    act: (cubit) => cubit.setEnabled(isEnabled: false),
    expect: () => [isA<LogReminderSettings>().having((settings) => settings.isEnabled, 'isEnabled', isFalse)],
  );

  blocTest<LogRemindersCubit, LogReminderSettings>(
    'picking a time moves that tracker only',
    build: () => CubitsFactories.buildLogRemindersCubit(
      getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped.withEnabled(isEnabled: true)),
      saveLogReminderSettingsUseCase: buildSettingsWriter(),
      syncLogRemindersUseCase: buildSync(),
      notificationService: buildPermissiveNotifications(),
    ),
    act: (cubit) => cubit.setTrackerTime(tracker: LogReminderTracker.water, hour: 11, minute: 15),
    expect: () => [
      isA<LogReminderSettings>()
          .having(
            (settings) => settings.scheduleFor(LogReminderTracker.water),
            'water',
            const LogReminderSchedule(isEnabled: true, minuteOfDay: 11 * 60 + 15),
          )
          .having(
            (settings) => settings.scheduleFor(LogReminderTracker.lunch).minuteOfDay,
            'lunch',
            LogReminderTracker.lunch.defaultMinuteOfDay,
          ),
    ],
  );

  test('a change is persisted and resynced', () async {
    final saveLogReminderSettingsUseCase = buildSettingsWriter();
    final syncLogRemindersUseCase = buildSync();
    final cubit = CubitsFactories.buildLogRemindersCubit(
      getLogReminderSettingsUseCase: buildSettingsReader(LogReminderSettings.shipped.withEnabled(isEnabled: true)),
      saveLogReminderSettingsUseCase: saveLogReminderSettingsUseCase,
      syncLogRemindersUseCase: syncLogRemindersUseCase,
      notificationService: buildPermissiveNotifications(),
    );

    await cubit.setTrackerEnabled(tracker: LogReminderTracker.sleep, isEnabled: false);

    verify(() => saveLogReminderSettingsUseCase(cubit.state)).called(1);
    verify(() => syncLogRemindersUseCase(loggedByTracker: any(named: 'loggedByTracker'))).called(1);
    await cubit.close();
  });
}
