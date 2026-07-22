import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_filter.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';
import 'package:vitta/app/domain/reminder/use_cases/complete_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/create_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/delete_reminder_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/get_reminders_for_date_use_case.dart';
import 'package:vitta/app/domain/reminder/use_cases/update_reminder_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_presentation_event.dart';
import 'package:vitta/app/presentation/pages/reminder/reminder_state.dart';

class ReminderCubit extends PresentationCubit<ReminderState, ReminderPresentationEvent> {
  ReminderCubit({
    required this._getRemindersForDateUseCase,
    required this._createReminderUseCase,
    required this._updateReminderUseCase,
    required this._completeReminderUseCase,
    required this._deleteReminderUseCase,
    required this._notificationService,
  }) : super(ReminderState(isLoaded: false, date: _dateOnly(DateTime.now()), reminders: const [], filter: .all));

  final GetRemindersForDateUseCase _getRemindersForDateUseCase;
  final CreateReminderUseCase _createReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;
  final CompleteReminderUseCase _completeReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;
  final NotificationService _notificationService;

  static DateTime _dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  @override
  void onInit() => loadDate(state.date);

  Future<void> loadDate(DateTime date) async {
    final day = _dateOnly(date);
    final remindersResult = await withLoadingOverlay(
      () => _getRemindersForDateUseCase(date: day),
      showOverlay: state.isLoaded,
      showLoadingEvent: ReminderShowLoading(),
      hideLoadingEvent: ReminderHideLoading(),
    );
    remindersResult.when(
      (error) => emitPresentation(ReminderError(message: error.message)),
      (reminders) => emit(ReminderState(date: day, reminders: reminders, filter: state.filter)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> previousDay() => loadDate(state.date.subtract(const Duration(days: 1)));

  Future<void> nextDay() => loadDate(state.date.add(const Duration(days: 1)));

  Future<void> goToDate(DateTime date) => loadDate(date);

  void changeFilter(ReminderFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> createReminder({
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) async {
    emitPresentation(ReminderShowLoading());
    final createdResult = await _createReminderUseCase(title: title, dueDate: dueDate, notes: notes, remindAt: remindAt, recurrence: recurrence);
    emitPresentation(ReminderHideLoading());
    final created = createdResult.when((error) {
      emitPresentation(ReminderError(message: error.message));
      return null;
    }, (reminder) => reminder);
    if (created == null) {
      return;
    }
    Log.action(.reminderCreated, data: {'recurrence': created.recurrence.name});
    await _scheduleReminder(created);
    if (_dateOnly(created.dueDate) == state.date) {
      emit(state.copyWith(reminders: [...state.reminders, created]));
    }
  }

  Future<void> updateReminder({
    required Reminder original,
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) async {
    emitPresentation(ReminderShowLoading());
    final updatedResult = await _updateReminderUseCase(
      reminderId: original.id,
      title: title,
      dueDate: dueDate,
      notes: notes,
      remindAt: remindAt,
      recurrence: recurrence,
    );
    emitPresentation(ReminderHideLoading());
    final updated = updatedResult.when((error) {
      emitPresentation(ReminderError(message: error.message));
      return null;
    }, (reminder) => reminder);
    if (updated == null) {
      return;
    }
    await _notificationService.cancel(updated.notificationId);
    await _scheduleReminder(updated);
    final stillOnDay = _dateOnly(updated.dueDate) == state.date;
    final reminders = [
      for (final reminder in state.reminders)
        if (reminder.id != updated.id) reminder else if (stillOnDay) updated,
    ];
    emit(state.copyWith(reminders: reminders));
  }

  Future<void> setCompleted({required Reminder reminder, required bool completed}) async {
    final previous = state.reminders;
    emit(
      state.copyWith(
        reminders: [
          for (final item in previous)
            if (item.id == reminder.id) item.toggledCompletion(completed: completed) else item,
        ],
      ),
    );
    final completionResult = await _completeReminderUseCase(reminder: reminder, completed: completed);
    final completion = completionResult.when((error) {
      emit(state.copyWith(reminders: previous));
      emitPresentation(ReminderError(message: error.message));
      return null;
    }, (value) => value);
    if (completion == null) {
      return;
    }
    Log.action(.reminderCompleted, data: {'completed': completed});

    if (completed) {
      await _notificationService.cancel(reminder.notificationId);
    } else {
      await _scheduleReminder(completion.reminder);
    }

    var reminders = [
      for (final item in state.reminders)
        if (item.id == completion.reminder.id) completion.reminder else item,
    ];
    final next = completion.nextOccurrence;
    if (next != null) {
      await _scheduleReminder(next);
      if (_dateOnly(next.dueDate) == state.date) {
        reminders = [...reminders, next];
      }
    }
    emit(state.copyWith(reminders: reminders));
  }

  Future<void> deleteReminder({required Reminder reminder}) async {
    final previous = state.reminders;
    emit(
      state.copyWith(
        reminders: [
          for (final item in previous)
            if (item.id != reminder.id) item,
        ],
      ),
    );
    final deletedResult = await _deleteReminderUseCase(reminderId: reminder.id);
    final error = deletedResult.when((error) => error, (_) => null);
    if (error != null) {
      emit(state.copyWith(reminders: previous));
      emitPresentation(ReminderError(message: error.message));
      return;
    }
    Log.action(.reminderDeleted);
    await _notificationService.cancel(reminder.notificationId);
  }

  Future<void> _scheduleReminder(Reminder reminder) async {
    final remindAt = reminder.remindAt;
    if (remindAt == null || reminder.isCompleted) {
      return;
    }
    await _notificationService.requestPermission();
    await _notificationService.scheduleReminder(id: reminder.notificationId, title: reminder.title, body: reminder.notes ?? '', dateTime: remindAt);
  }
}
