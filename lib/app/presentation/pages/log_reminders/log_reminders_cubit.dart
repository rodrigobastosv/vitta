import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/domain/log_reminders/use_cases/get_log_reminder_settings_use_case.dart';
import 'package:vitta/app/domain/log_reminders/use_cases/save_log_reminder_settings_use_case.dart';
import 'package:vitta/app/domain/log_reminders/use_cases/sync_log_reminders_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_presentation_event.dart';

class LogRemindersCubit extends PresentationCubit<LogReminderSettings, LogRemindersPresentationEvent> {
  LogRemindersCubit({
    required GetLogReminderSettingsUseCase getLogReminderSettingsUseCase,
    required this._saveLogReminderSettingsUseCase,
    required this._syncLogRemindersUseCase,
    required this._notificationService,
  }) : super(getLogReminderSettingsUseCase());

  final SaveLogReminderSettingsUseCase _saveLogReminderSettingsUseCase;
  final SyncLogRemindersUseCase _syncLogRemindersUseCase;
  final NotificationService _notificationService;

  Future<void> setEnabled({required bool isEnabled}) async {
    if (isEnabled) {
      final isPermitted = await _notificationService.requestPermission();
      if (!isPermitted) {
        emitPresentation(LogRemindersPermissionDenied());
        return;
      }
    }
    await _apply(state.withEnabled(isEnabled: isEnabled));
  }

  Future<void> setTrackerEnabled({required LogReminderTracker tracker, required bool isEnabled}) =>
      _apply(state.withSchedule(tracker: tracker, schedule: state.scheduleFor(tracker).copyWith(isEnabled: isEnabled)));

  Future<void> setTrackerTime({required LogReminderTracker tracker, required int hour, required int minute}) =>
      _apply(state.withSchedule(tracker: tracker, schedule: state.scheduleFor(tracker).copyWith(minuteOfDay: hour * 60 + minute)));

  Future<void> setTrackerInterval({required LogReminderTracker tracker, required int? intervalHours}) =>
      _apply(state.withSchedule(tracker: tracker, schedule: state.scheduleFor(tracker).withInterval(intervalHours)));

  Future<void> _apply(LogReminderSettings settings) async {
    emit(settings);
    await _saveLogReminderSettingsUseCase(settings);
    Log.action(
      'log_reminders_changed',
      data: {
        'enabled': settings.isEnabled,
        'active_trackers': LogReminderTracker.values.where(settings.isActiveFor).length,
      },
    );
    await _syncLogRemindersUseCase(loggedByTracker: {for (final tracker in LogReminderTracker.values) tracker: false});
  }
}
