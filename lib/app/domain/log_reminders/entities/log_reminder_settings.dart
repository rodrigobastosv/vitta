import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';

class LogReminderSettings extends Equatable {
  const LogReminderSettings({required this.isEnabled, required this.schedules});

  static final LogReminderSettings shipped = LogReminderSettings(
    isEnabled: false,
    schedules: {
      for (final tracker in LogReminderTracker.values) tracker: LogReminderSchedule(isEnabled: true, minuteOfDay: tracker.defaultMinuteOfDay),
    },
  );

  final bool isEnabled;
  final Map<LogReminderTracker, LogReminderSchedule> schedules;

  LogReminderSchedule scheduleFor(LogReminderTracker tracker) =>
      schedules[tracker] ?? LogReminderSchedule(isEnabled: true, minuteOfDay: tracker.defaultMinuteOfDay);

  bool isActiveFor(LogReminderTracker tracker) => isEnabled && scheduleFor(tracker).isEnabled;

  LogReminderSettings withEnabled({required bool isEnabled}) => LogReminderSettings(isEnabled: isEnabled, schedules: schedules);

  LogReminderSettings withSchedule({required LogReminderTracker tracker, required LogReminderSchedule schedule}) =>
      LogReminderSettings(isEnabled: isEnabled, schedules: {...schedules, tracker: schedule});

  @override
  List<Object?> get props => [isEnabled, schedules];
}
