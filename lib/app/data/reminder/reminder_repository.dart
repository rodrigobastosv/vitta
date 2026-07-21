import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/reminder/datasources/supabase/supabase_reminder_datasource.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_completion.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

class ReminderRepository {
  ReminderRepository({required this._supabaseReminderDataSource});

  final SupabaseReminderDataSource _supabaseReminderDataSource;

  Future<Result<VTError, List<Reminder>>> getRemindersForDate({required DateTime date}) => _supabaseReminderDataSource.getRemindersForDate(date: date);

  Future<Result<VTError, Map<DateTime, List<Reminder>>>> getRemindersInRange({required DateTime from, required DateTime to}) async {
    final remindersResult = await _supabaseReminderDataSource.getRemindersInRange(from: from, to: to);
    return remindersResult.when(Failure.new, (reminders) => Success(_groupByDate(reminders)));
  }

  Map<DateTime, List<Reminder>> _groupByDate(List<Reminder> reminders) {
    final remindersByDate = <DateTime, List<Reminder>>{};
    for (final reminder in reminders) {
      final day = DateTime(reminder.dueDate.year, reminder.dueDate.month, reminder.dueDate.day);
      remindersByDate.putIfAbsent(day, () => []).add(reminder);
    }
    return remindersByDate;
  }

  Future<Result<VTError, Reminder>> createReminder({
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) => _supabaseReminderDataSource.createReminder(title: title, dueDate: dueDate, notes: notes, remindAt: remindAt, recurrence: recurrence);

  Future<Result<VTError, Reminder>> updateReminder({
    required String reminderId,
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) => _supabaseReminderDataSource.updateReminder(
    reminderId: reminderId,
    title: title,
    dueDate: dueDate,
    notes: notes,
    remindAt: remindAt,
    recurrence: recurrence,
  );

  Future<Result<VTError, void>> deleteReminder({required String reminderId}) => _supabaseReminderDataSource.deleteReminder(reminderId: reminderId);

  // Completing a recurring reminder spawns its next occurrence (sequential writes, no
  // RPC, same shape as SaveRecipeUseCase); un-completing or a one-off just flips the flag.
  Future<Result<VTError, ReminderCompletion>> completeReminder({required Reminder reminder, required bool completed}) async {
    final updatedResult = await _supabaseReminderDataSource.setCompleted(reminderId: reminder.id, completedAt: completed ? DateTime.now() : null);
    final updateError = updatedResult.when((error) => error, (_) => null);
    if (updateError != null) {
      return Failure(updateError);
    }
    final updated = updatedResult.when((_) => reminder, (value) => value);

    if (!completed || !reminder.isRecurring) {
      return Success(ReminderCompletion(reminder: updated));
    }

    final schedule = reminder.nextOccurrenceSchedule();
    final spawnedResult = await _supabaseReminderDataSource.createReminder(
      title: reminder.title,
      dueDate: schedule.dueDate,
      notes: reminder.notes,
      remindAt: schedule.remindAt,
      recurrence: reminder.recurrence,
    );
    return spawnedResult.when(Failure.new, (spawned) => Success(ReminderCompletion(reminder: updated, nextOccurrence: spawned)));
  }
}
