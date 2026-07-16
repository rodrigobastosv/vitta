import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_exercise_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_routine_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_workout_datasource.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression_point.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class WorkoutRepository {
  WorkoutRepository({
    required this._supabaseExerciseDataSource,
    required this._supabaseWorkoutDataSource,
    required this._supabaseRoutineDataSource,
  });

  final SupabaseExerciseDataSource _supabaseExerciseDataSource;
  final SupabaseWorkoutDataSource _supabaseWorkoutDataSource;
  final SupabaseRoutineDataSource _supabaseRoutineDataSource;

  Future<Result<VTError, List<Exercise>>> searchExercises({required String query, MuscleGroup? muscleGroup}) =>
      _supabaseExerciseDataSource.searchCatalog(query: query, muscleGroup: muscleGroup);

  Future<Result<VTError, Exercise>> getExercise({required String exerciseId}) =>
      _supabaseExerciseDataSource.getExercise(exerciseId: exerciseId);

  Future<Result<VTError, List<Workout>>> getWorkoutsForDate({required DateTime date}) =>
      _supabaseWorkoutDataSource.getWorkoutsInRange(from: date, to: date);

  Future<Result<VTError, List<Workout>>> getWorkoutsInRange({required DateTime from, required DateTime to}) =>
      _supabaseWorkoutDataSource.getWorkoutsInRange(from: from, to: to);

  Future<Result<VTError, Workout>> createWorkout({required DateTime performedDate, String? notes, String? routineId}) =>
      _supabaseWorkoutDataSource.createWorkout(performedDate: performedDate, notes: notes, routineId: routineId);

  Future<Result<VTError, void>> deleteWorkout({required String workoutId}) =>
      _supabaseWorkoutDataSource.deleteWorkout(workoutId: workoutId);

  Future<Result<VTError, WorkoutExercise>> addWorkoutExercise({required String workoutId, required String exerciseId}) =>
      _supabaseWorkoutDataSource.addWorkoutExercise(workoutId: workoutId, exerciseId: exerciseId);

  Future<Result<VTError, WorkoutExercise>> setWorkoutExerciseCompleted({required String workoutExerciseId, required bool completed}) =>
      _supabaseWorkoutDataSource.setWorkoutExerciseCompleted(workoutExerciseId: workoutExerciseId, completed: completed);

  Future<Result<VTError, void>> removeWorkoutExercise({required String workoutExerciseId}) =>
      _supabaseWorkoutDataSource.removeWorkoutExercise(workoutExerciseId: workoutExerciseId);

  Future<Result<VTError, WorkoutSet>> logSet({required String workoutExerciseId, required int reps, required double weightKg}) =>
      _supabaseWorkoutDataSource.logSet(workoutExerciseId: workoutExerciseId, reps: reps, weightKg: weightKg);

  Future<Result<VTError, WorkoutSet>> updateSet({required String setId, required int reps, required double weightKg}) =>
      _supabaseWorkoutDataSource.updateSet(setId: setId, reps: reps, weightKg: weightKg);

  Future<Result<VTError, void>> deleteSet({required String setId}) => _supabaseWorkoutDataSource.deleteSet(setId: setId);

  Future<Result<VTError, List<Routine>>> getRoutines() => _supabaseRoutineDataSource.getRoutines();

  Future<Result<VTError, Routine>> createRoutine({required String name, required List<String> exerciseIds}) =>
      _supabaseRoutineDataSource.createRoutine(name: name, exerciseIds: exerciseIds);

  Future<Result<VTError, Routine>> updateRoutine({required String routineId, required String name, required List<String> exerciseIds}) =>
      _supabaseRoutineDataSource.updateRoutine(routineId: routineId, name: name, exerciseIds: exerciseIds);

  Future<Result<VTError, void>> deleteRoutine({required String routineId}) =>
      _supabaseRoutineDataSource.deleteRoutine(routineId: routineId);

  Future<Result<VTError, void>> reorderRoutines({required List<String> orderedRoutineIds}) =>
      _supabaseRoutineDataSource.reorderRoutines(orderedRoutineIds: orderedRoutineIds);

  Future<Result<VTError, RoutineCycle>> getRoutineCycle() async {
    final routinesResult = await getRoutines();
    final routinesError = routinesResult.when((error) => error, (_) => null);
    if (routinesError != null) {
      return Failure(routinesError);
    }
    final lastRoutineIdResult = await _supabaseRoutineDataSource.getLastUsedRoutineId();
    return lastRoutineIdResult.when(
      Failure.new,
      (lastRoutineId) =>
          Success(RoutineCycle(routines: routinesResult.when((_) => const [], (value) => value), lastRoutineId: lastRoutineId)),
    );
  }

  Future<Result<VTError, Map<String, List<WorkoutSet>>>> getLastSetsByExercise({required List<String> exerciseIds, DateTime? before}) =>
      _supabaseWorkoutDataSource.getLastSetsByExercise(exerciseIds: exerciseIds, before: before);

  Future<Result<VTError, void>> logSetsBulk({required Map<String, List<WorkoutSet>> setsByWorkoutExercise}) =>
      _supabaseWorkoutDataSource.logSetsBulk(setsByWorkoutExercise: setsByWorkoutExercise);

  Future<Result<VTError, List<Exercise>>> getLoggedExercises() => _supabaseWorkoutDataSource.getLoggedExercises();

  Future<Result<VTError, ExerciseProgression>> getExerciseProgression({required String exerciseId}) async {
    final sessionsResult = await _supabaseWorkoutDataSource.getSessionsForExercise(exerciseId: exerciseId);
    return sessionsResult.when(Failure.new, (sessions) => Success(_toProgression(sessions)));
  }

  ExerciseProgression _toProgression(List<(DateTime, List<WorkoutSet>)> sessions) {
    final setsByDate = <DateTime, List<WorkoutSet>>{};
    for (final (performedDate, sets) in sessions) {
      final date = DateTime(performedDate.year, performedDate.month, performedDate.day);
      setsByDate.putIfAbsent(date, () => []).addAll(sets);
    }
    final points = [for (final MapEntry(:key, :value) in setsByDate.entries) ExerciseProgressionPoint(date: key, sets: value)]
      ..sort((a, b) => a.date.compareTo(b.date));
    return ExerciseProgression(points: points);
  }
}
