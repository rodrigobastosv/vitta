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
          .order('performed_date');
      return Success(rows.map(Workout.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load workouts', cause: error));
    }
  }

  Future<Result<VTError, Workout>> createWorkout({required DateTime performedDate, String? notes}) async {
    try {
      final request = CreateWorkoutRequest(userId: _userId, performedDate: performedDate, notes: notes);
      final row = await _supabaseService.from(.workouts).insert(request.toJson()).select(_workoutSelect).single();
      return Success(Workout.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create workout', cause: error));
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
