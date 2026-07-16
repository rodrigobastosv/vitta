import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_exercise_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_set_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/update_workout_set_request.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class SupabaseWorkoutDataSource {
  SupabaseWorkoutDataSource({required this._supabaseService});

  /// How far back getLastSetsByExercise looks. Bounded so a user with years
  /// of history doesn't drag their whole log over the wire to pre-fill one
  /// routine; an exercise not trained within this many workouts simply starts
  /// empty, which is the same as never having done it.
  static const _lastSetsWorkoutLookback = 60;

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  String get _workoutSelect =>
      '*, ${SupabaseTable.workoutExercises.wireName}(*, ${SupabaseTable.exercises.wireName}(*), ${SupabaseTable.workoutSets.wireName}(*))';

  Future<Result<VTError, List<Workout>>> getWorkoutsInRange({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.workouts)
          .select(_workoutSelect)
          .eq('user_id', _userId)
          .gte('performed_date', _toDateString(from))
          .lte('performed_date', _toDateString(to))
          // Explicit: order() defaults to descending, and a range of days is
          // read chronologically.
          .order('performed_date', ascending: true);
      return Success(rows.map(Workout.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load workouts', cause: error));
    }
  }

  Future<Result<VTError, Workout>> createWorkout({required DateTime performedDate, String? notes, String? routineId}) async {
    try {
      final request = CreateWorkoutRequest(userId: _userId, performedDate: performedDate, notes: notes, routineId: routineId);
      final row = await _supabaseService.from(.workouts).insert(request.toJson()).select(_workoutSelect).single();
      return Success(Workout.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create workout', cause: error));
    }
  }

  /// The sets performed the last time each of `exerciseIds` was trained, keyed
  /// by exercise.
  ///
  /// Queried from the `workouts` side rather than `workout_exercises` because
  /// PostgREST's `order` on an embedded resource sorts the *embedded* rows, not
  /// the parents - ordering workout_exercises by `workouts(performed_date)`
  /// would silently not sort anything. Walking workouts newest-first and taking
  /// the first hit per exercise gives the real "last time" instead.
  ///
  /// [before] excludes that day and everything after it, so the "last time"
  /// hint shown on a day's own card (issue #95) means the *previous* session
  /// rather than the sets already sitting on screen. Null (the routine-start
  /// and standalone-add callers) keeps every session in scope.
  Future<Result<VTError, Map<String, List<WorkoutSet>>>> getLastSetsByExercise({
    required List<String> exerciseIds,
    DateTime? before,
  }) async {
    if (exerciseIds.isEmpty) {
      return const Success({});
    }
    try {
      var query = _supabaseService
          .from(.workouts)
          .select(
            'performed_date, ${SupabaseTable.workoutExercises.wireName}!inner(exercise_id, ${SupabaseTable.workoutSets.wireName}(*))',
          )
          .eq('user_id', _userId)
          .inFilter('${SupabaseTable.workoutExercises.wireName}.exercise_id', exerciseIds);
      if (before != null) {
        query = query.lt('performed_date', _toDateString(before));
      }
      final rows = await query.order('performed_date', ascending: false).limit(_lastSetsWorkoutLookback);

      final lastSets = <String, List<WorkoutSet>>{};
      for (final row in rows) {
        final workoutExercises = (row[SupabaseTable.workoutExercises.wireName] as List<dynamic>).cast<Map<String, dynamic>>();
        for (final workoutExercise in workoutExercises) {
          final exerciseId = workoutExercise['exercise_id'] as String;
          if (lastSets.containsKey(exerciseId)) {
            continue;
          }
          final sets = (workoutExercise[SupabaseTable.workoutSets.wireName] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(WorkoutSet.fromMap)
              .toList()
            ..sort((a, b) => a.position.compareTo(b.position));
          if (sets.isNotEmpty) {
            lastSets[exerciseId] = sets;
          }
        }
      }
      return Success(lastSets);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load previous sets', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteWorkout({required String workoutId}) async {
    try {
      await _supabaseService.from(.workouts).delete().eq('id', workoutId).eq('user_id', _userId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete workout $workoutId', cause: error));
    }
  }

  Future<Result<VTError, WorkoutExercise>> addWorkoutExercise({required String workoutId, required String exerciseId}) async {
    try {
      final request = CreateWorkoutExerciseRequest(
        workoutId: workoutId,
        exerciseId: exerciseId,
        position: await _nextPosition(table: .workoutExercises, column: 'workout_id', parentId: workoutId),
      );
      final row = await _supabaseService
          .from(.workoutExercises)
          .insert(request.toJson())
          .select('*, ${SupabaseTable.exercises.wireName}(*), ${SupabaseTable.workoutSets.wireName}(*)')
          .single();
      return Success(WorkoutExercise.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to add exercise $exerciseId to workout $workoutId', cause: error));
    }
  }

  /// Marks an exercise done, or un-marks it. `completed` false writes null
  /// rather than a timestamp, so unmarking is a real undo - the same column
  /// answers both, and a mistaken tap costs nothing.
  Future<Result<VTError, WorkoutExercise>> setWorkoutExerciseCompleted({
    required String workoutExerciseId,
    required bool completed,
  }) async {
    try {
      final row = await _supabaseService
          .from(.workoutExercises)
          .update({'completed_at': completed ? DateTime.now().toUtc().toIso8601String() : null})
          .eq('id', workoutExerciseId)
          .select('*, ${SupabaseTable.exercises.wireName}(*), ${SupabaseTable.workoutSets.wireName}(*)')
          .single();
      return Success(WorkoutExercise.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update workout exercise $workoutExerciseId', cause: error));
    }
  }

  Future<Result<VTError, void>> removeWorkoutExercise({required String workoutExerciseId}) async {
    try {
      await _supabaseService.from(.workoutExercises).delete().eq('id', workoutExerciseId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to remove workout exercise $workoutExerciseId', cause: error));
    }
  }

  Future<Result<VTError, WorkoutSet>> logSet({required String workoutExerciseId, required int reps, required double weightKg}) async {
    try {
      final request = CreateWorkoutSetRequest(
        workoutExerciseId: workoutExerciseId,
        position: await _nextPosition(table: .workoutSets, column: 'workout_exercise_id', parentId: workoutExerciseId),
        reps: reps,
        weightKg: weightKg,
      );
      final row = await _supabaseService.from(.workoutSets).insert(request.toJson()).select().single();
      return Success(WorkoutSet.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log set on workout exercise $workoutExerciseId', cause: error));
    }
  }

  /// Inserts every set of every exercise in one round trip. Starting a routine
  /// pre-fills ~6 exercises x ~4 sets; doing that through logSet would be two
  /// dozen sequential inserts, and the positions are already known here.
  Future<Result<VTError, void>> logSetsBulk({required Map<String, List<WorkoutSet>> setsByWorkoutExercise}) async {
    final requests = [
      for (final MapEntry(key: workoutExerciseId, value: sets) in setsByWorkoutExercise.entries)
        for (final (index, set) in sets.indexed)
          CreateWorkoutSetRequest(
            workoutExerciseId: workoutExerciseId,
            position: index,
            reps: set.reps,
            weightKg: set.weightKg,
          ).toJson(),
    ];
    if (requests.isEmpty) {
      return const Success(null);
    }
    try {
      await _supabaseService.from(.workoutSets).insert(requests);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to pre-fill sets', cause: error));
    }
  }

  Future<Result<VTError, WorkoutSet>> updateSet({required String setId, required int reps, required double weightKg}) async {
    try {
      final request = UpdateWorkoutSetRequest(reps: reps, weightKg: weightKg);
      final row = await _supabaseService.from(.workoutSets).update(request.toJson()).eq('id', setId).select().single();
      return Success(WorkoutSet.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update set $setId', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteSet({required String setId}) async {
    try {
      await _supabaseService.from(.workoutSets).delete().eq('id', setId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete set $setId', cause: error));
    }
  }

  Future<int> _nextPosition({required SupabaseTable table, required String column, required String parentId}) async {
    final rows = await _supabaseService.from(table).select('position').eq(column, parentId).order('position', ascending: false).limit(1);
    if (rows.isEmpty) {
      return 0;
    }
    return ((rows.first['position'] as num).toInt()) + 1;
  }

  String _toDateString(DateTime date) => date.toIso8601String().split('T').first;
}
