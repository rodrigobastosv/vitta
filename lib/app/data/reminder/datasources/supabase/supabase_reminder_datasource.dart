import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/reminder/datasources/supabase/requests/create_reminder_request.dart';
import 'package:vitta/app/data/reminder/datasources/supabase/requests/update_reminder_request.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';

class SupabaseReminderDataSource {
  SupabaseReminderDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, List<Reminder>>> getRemindersForDate({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from(.reminders)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .eq('due_date', date.toIso8601String().split('T').first)
          .order('created_at', ascending: true);
      return Success(rows.map(Reminder.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load reminders for $date', cause: error));
    }
  }

  Future<Result<VTError, List<Reminder>>> getRemindersInRange({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.reminders)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .gte('due_date', from.toIso8601String().split('T').first)
          .lte('due_date', to.toIso8601String().split('T').first)
          .order('created_at', ascending: true);
      return Success(rows.map(Reminder.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load reminders in range', cause: error));
    }
  }

  Future<Result<VTError, Reminder>> createReminder({
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) async {
    try {
      final request = CreateReminderRequest(
        userId: _supabaseService.currentUserId,
        title: title,
        dueDate: dueDate,
        notes: notes,
        remindAt: remindAt,
        recurrence: recurrence,
      );
      final row = await _supabaseService.from(.reminders).insert(request.toJson()).select().single();
      return Success(Reminder.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create reminder', cause: error));
    }
  }

  Future<Result<VTError, Reminder>> updateReminder({
    required String reminderId,
    required String title,
    required DateTime dueDate,
    String? notes,
    DateTime? remindAt,
    ReminderRecurrence recurrence = .none,
  }) async {
    try {
      final request = UpdateReminderRequest(title: title, dueDate: dueDate, notes: notes, remindAt: remindAt, recurrence: recurrence);
      final row = await _supabaseService
          .from(.reminders)
          .update(request.toJson())
          .eq('id', reminderId)
          .eq('user_id', _supabaseService.currentUserId)
          .select()
          .single();
      return Success(Reminder.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update reminder $reminderId', cause: error));
    }
  }

  Future<Result<VTError, Reminder>> setCompleted({required String reminderId, required DateTime? completedAt}) async {
    try {
      final row = await _supabaseService
          .from(.reminders)
          .update({'completed_at': completedAt?.toUtc().toIso8601String()})
          .eq('id', reminderId)
          .eq('user_id', _supabaseService.currentUserId)
          .select()
          .single();
      return Success(Reminder.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update reminder $reminderId', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteReminder({required String reminderId}) async {
    try {
      await _supabaseService.from(.reminders).delete().eq('id', reminderId).eq('user_id', _supabaseService.currentUserId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete reminder $reminderId', cause: error));
    }
  }
}
