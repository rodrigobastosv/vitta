import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_cubit.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_page.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminder_tracker_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(LogReminderSettings.shipped));

  Future<LogRemindersCubit> pumpLogReminders(WidgetTester tester, {required LogReminderSettings settings}) async {
    final getLogReminderSettingsUseCase = MockGetLogReminderSettingsUseCase();
    when(getLogReminderSettingsUseCase.call).thenReturn(settings);
    final saveLogReminderSettingsUseCase = MockSaveLogReminderSettingsUseCase();
    when(() => saveLogReminderSettingsUseCase(any())).thenAnswer((_) async {});
    final syncLogRemindersUseCase = MockSyncLogRemindersUseCase();
    when(() => syncLogRemindersUseCase(loggedByTracker: any(named: 'loggedByTracker'))).thenAnswer((_) async {});
    final notificationService = MockNotificationService();
    when(notificationService.requestPermission).thenAnswer((_) async => true);
    final cubit = CubitsFactories.buildLogRemindersCubit(
      getLogReminderSettingsUseCase: getLogReminderSettingsUseCase,
      saveLogReminderSettingsUseCase: saveLogReminderSettingsUseCase,
      syncLogRemindersUseCase: syncLogRemindersUseCase,
      notificationService: notificationService,
    );

    if (G.isRegistered<LogRemindersCubit>()) {
      G.unregister<LogRemindersCubit>();
    }
    G.registerFactory<LogRemindersCubit>(() => cubit);
    addTearDown(() => G.unregister<LogRemindersCubit>());

    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LogRemindersPage(),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('every tracker gets its own row', (tester) async {
    await pumpLogReminders(tester, settings: LogReminderSettings.shipped);

    expect(find.byType(LogReminderTrackerTile), findsNWidgets(LogReminderTracker.values.length));
  });

  testWidgets('per-tracker rows are inert until the master switch is on', (tester) async {
    await pumpLogReminders(tester, settings: LogReminderSettings.shipped);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();

    expect(switches.first.value, isFalse);
    expect(switches.skip(1).every((control) => control.onChanged == null), isTrue);
  });

  testWidgets('turning the master switch on hands the rows back to the user', (tester) async {
    final cubit = await pumpLogReminders(tester, settings: LogReminderSettings.shipped);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(cubit.state.isEnabled, isTrue);
    expect(tester.widgetList<Switch>(find.byType(Switch)).skip(1).every((control) => control.onChanged != null), isTrue);
  });
}
