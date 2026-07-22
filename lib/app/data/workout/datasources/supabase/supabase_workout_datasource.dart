import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_exercise_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/create_workout_set_request.dart';
import 'package:vitta/app/data/workout/datasources/supabase/requests/update_workout_set_request.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class SupabaseWorkoutDataSource {
  SupabaseWorkoutDataSource({required this._supabaseService});

  static const _lastSetsWorkoutLookback = 60;

  static const _progressionWorkoutLookback = 60;

  static const _loggedExercisesWorkoutLookback = 500;

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

  Future<Result<VTError, Map<String, List<WorkoutSet>>>> getLastSetsByExercise({required List<String> exerciseIds, DateTime? before}) async {
    if (exerciseIds.isEmpty) {
      return const Success({});
    }
    try {
      var query = _supabaseService
          .from(.workouts)
          .select('performed_date, ${SupabaseTable.workoutExercises.wireName}!inner(exercise_id, ${SupabaseTable.workoutSets.wireName}(*))')
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
          final sets =
              (workoutExercise[SupabaseTable.workoutSets.wireName] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>().map(WorkoutSet.fromMap).toList()
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

  Future<Result<VTError, List<(DateTime, List<WorkoutSet>)>>> getSessionsForExercise({required String exerciseId}) async {
    try {
      final rows = await _supabaseService
          .from(.workouts)
          .select('performed_date, ${SupabaseTable.workoutExercises.wireName}!inner(exercise_id, ${SupabaseTable.workoutSets.wireName}(*))')
          .eq('user_id', _userId)
          .eq('${SupabaseTable.workoutExercises.wireName}.exercise_id', exerciseId)
          .order('performed_date', ascending: false)
          .limit(_progressionWorkoutLookback);

      final sessions = <(DateTime, List<WorkoutSet>)>[];
      for (final row in rows) {
        final performedDate = DateTime.parse(row['performed_date'] as String);
        final workoutExercises = (row[SupabaseTable.workoutExercises.wireName] as List<dynamic>).cast<Map<String, dynamic>>();
        final sets = [
          for (final workoutExercise in workoutExercises)
            ...(workoutExercise[SupabaseTable.workoutSets.wireName] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>().map(WorkoutSet.fromMap),
        ]..sort((a, b) => a.position.compareTo(b.position));
        if (sets.isNotEmpty) {
          sessions.add((performedDate, sets));
        }
      }
      return Success(sessions);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load progression for exercise $exerciseId', cause: error));
    }
  }

  Future<Result<VTError, List<Exercise>>> getLoggedExercises() async {
    try {
      final rows = await _supabaseService
          .from(.workouts)
          .select('${SupabaseTable.workoutExercises.wireName}(position, ${SupabaseTable.exercises.wireName}(*))')
          .eq('user_id', _userId)
          .order('performed_date', ascending: false)
          .limit(_loggedExercisesWorkoutLookback);

      final exercises = <Exercise>[];
      final seenExerciseIds = <String>{};
      for (final row in rows) {
        final workoutExercises = (row[SupabaseTable.workoutExercises.wireName] as List<dynamic>).cast<Map<String, dynamic>>()
          ..sort((a, b) => (a['position'] as num).compareTo(b['position'] as num));
        for (final workoutExercise in workoutExercises) {
          final exerciseRow = workoutExercise[SupabaseTable.exercises.wireName] as Map<String, dynamic>?;
          if (exerciseRow == null) {
            continue;
          }
          final exercise = Exercise.fromMap(exerciseRow);
          if (seenExerciseIds.add(exercise.id)) {
            exercises.add(exercise);
          }
        }
      }
      return Success(exercises);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load logged exercises', cause: error));
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

  Future<Result<VTError, WorkoutExercise>> setWorkoutExerciseCompleted({required String workoutExerciseId, required bool completed}) async {
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

  Future<Result<VTError, WorkoutSet>> logSet({required String workoutExerciseId, required SetInput input}) async {
    try {
      final request = CreateWorkoutSetRequest(
        workoutExerciseId: workoutExerciseId,
        position: await _nextPosition(table: .workoutSets, column: 'workout_exercise_id', parentId: workoutExerciseId),
        reps: input.reps,
        weightKg: input.weightKg,
        durationSeconds: input.durationSeconds,
        distanceMeters: input.distanceMeters,
      );
      final row = await _supabaseService.from(.workoutSets).insert(request.toJson()).select().single();
      return Success(WorkoutSet.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log set on workout exercise $workoutExerciseId', cause: error));
    }
  }

  Future<Result<VTError, void>> logSetsBulk({required Map<String, List<WorkoutSet>> setsByWorkoutExercise}) async {
    final requests = [
      for (final MapEntry(key: workoutExerciseId, value: sets) in setsByWorkoutExercise.entries)
        for (final (index, set) in sets.indexed)
          CreateWorkoutSetRequest(
            workoutExerciseId: workoutExerciseId,
            position: index,
            reps: set.reps,
            weightKg: set.weightKg,
            durationSeconds: set.durationSeconds,
            distanceMeters: set.distanceMeters,
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

  Future<Result<VTError, WorkoutSet>> updateSet({required String setId, required SetInput input}) async {
    try {
      final request = UpdateWorkoutSetRequest(
        reps: input.reps,
        weightKg: input.weightKg,
        durationSeconds: input.durationSeconds,
        distanceMeters: input.distanceMeters,
      );
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
