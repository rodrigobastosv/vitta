import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/log_reminders/log_reminders_local_datasource.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';

import '../../../fixtures/local_storage_fixture.dart';

void main() {
  test('reminders are off until the user turns them on', () async {
    final dataSource = LogRemindersLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getLogReminderSettings().isEnabled, isFalse);
  });

  test('every tracker starts enabled at its own default time', () async {
    final dataSource = LogRemindersLocalDataSource(localStorageService: await buildTestLocalStorageService());

    final settings = dataSource.getLogReminderSettings();

    for (final tracker in LogReminderTracker.values) {
      expect(settings.scheduleFor(tracker), LogReminderSchedule(isEnabled: true, minuteOfDay: tracker.defaultMinuteOfDay));
    }
  });

  test('saved settings are read back', () async {
    final dataSource = LogRemindersLocalDataSource(localStorageService: await buildTestLocalStorageService());
    final settings = LogReminderSettings.shipped
        .withEnabled(isEnabled: true)
        .withSchedule(tracker: LogReminderTracker.water, schedule: const LogReminderSchedule(isEnabled: false, minuteOfDay: 11 * 60 + 15));

    await dataSource.saveLogReminderSettings(settings);

    expect(dataSource.getLogReminderSettings(), settings);
  });
}
