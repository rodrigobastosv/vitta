import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_routine_exercise_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_routine_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/update_routine_request.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class SupabaseRoutineDataSource {
  SupabaseRoutineDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  String get _routineSelect =>
      '*, ${SupabaseTable.routineExercises.wireName}(*, ${SupabaseTable.exercises.wireName}(*))';

  Future<Result<VTError, List<Routine>>> getRoutines() async {
    try {
      final rows = await _supabaseService
          .from(.routines)
          .select(_routineSelect)
          .eq('user_id', _userId)
          .order('position');
      return Success(rows.map(Routine.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load routines', cause: error));
    }
  }

  /// The routine of the most recent workout that came from one, which is what
  /// `RoutineCycle` advances from. Null when the user has never trained from a
  /// routine - a workout with no `routine_id` doesn't participate in the cycle,
  /// so it's filtered out here rather than being treated as "no routine".
  Future<Result<VTError, String?>> getLastUsedRoutineId() async {
    try {
      final row = await _supabaseService
          .from(.workouts)
          .select('routine_id')
          .eq('user_id', _userId)
          .not('routine_id', 'is', null)
          .order('performed_date', ascending: false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return Success(row?['routine_id'] as String?);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load the last used routine', cause: error));
    }
  }

  Future<Result<VTError, Routine>> createRoutine({required String name, required List<String> exerciseIds}) async {
    try {
      final request = CreateRoutineRequest(userId: _userId, name: name, position: await _nextPosition());
      final row = await _supabaseService.from(.routines).insert(request.toJson()).select().single();
      final routineId = row['id'] as String;
      await _replaceExercises(routineId: routineId, exerciseIds: exerciseIds);
      return _reload(routineId);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create routine "$name"', cause: error));
    }
  }

  Future<Result<VTError, Routine>> updateRoutine({
    required String routineId,
    required String name,
    required List<String> exerciseIds,
  }) async {
    try {
      await _supabaseService
          .from(.routines)
          .update(UpdateRoutineRequest(name: name).toJson())
          .eq('id', routineId)
          .eq('user_id', _userId);
      await _replaceExercises(routineId: routineId, exerciseIds: exerciseIds);
      return _reload(routineId);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update routine $routineId', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteRoutine({required String routineId}) async {
    try {
      await _supabaseService.from(.routines).delete().eq('id', routineId).eq('user_id', _userId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete routine $routineId', cause: error));
    }
  }

  /// Rewrites the cycle order. `position` is the whole point of a routine's
  /// order - it decides what RoutineCycle suggests next - so it has to be
  /// editable, not just assigned once at creation.
  ///
  /// Sequential updates rather than one upsert: an upsert would have to resend
  /// every not-null column (name, user_id) just to move an integer, and a user
  /// has a handful of routines, not thousands.
  Future<Result<VTError, void>> reorderRoutines({required List<String> orderedRoutineIds}) async {
    try {
      for (final (position, routineId) in orderedRoutineIds.indexed) {
        await _supabaseService
            .from(.routines)
            .update({'position': position})
            .eq('id', routineId)
            .eq('user_id', _userId);
      }
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to reorder routines', cause: error));
    }
  }

  /// Delete-then-insert rather than diffing: a routine is a short ordered list,
  /// and reconciling positions in place would be more code than rewriting them.
  /// The same call `SaveRecipeUseCase` makes for ingredients.
  Future<void> _replaceExercises({required String routineId, required List<String> exerciseIds}) async {
    await _supabaseService.from(.routineExercises).delete().eq('routine_id', routineId);
    if (exerciseIds.isEmpty) {
      return;
    }
    final requests = [
      for (final (index, exerciseId) in exerciseIds.indexed)
        CreateRoutineExerciseRequest(routineId: routineId, exerciseId: exerciseId, position: index).toJson(),
    ];
    await _supabaseService.from(.routineExercises).insert(requests);
  }

  Future<Result<VTError, Routine>> _reload(String routineId) async {
    final row = await _supabaseService.from(.routines).select(_routineSelect).eq('id', routineId).single();
    return Success(Routine.fromMap(row));
  }

  Future<int> _nextPosition() async {
    final rows = await _supabaseService
        .from(.routines)
        .select('position')
        .eq('user_id', _userId)
        .order('position', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      return 0;
    }
    return ((rows.first['position'] as num).toInt()) + 1;
  }
}
