import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_exercise_datasource.dart';
import 'package:vitta/app/data/workout/datasources/supabase/supabase_workout_datasource.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class WorkoutRepository {
  WorkoutRepository({required this._supabaseExerciseDataSource, required this._supabaseWorkoutDataSource});

  final SupabaseExerciseDataSource _supabaseExerciseDataSource;
  final SupabaseWorkoutDataSource _supabaseWorkoutDataSource;

  Future<Result<VTError, List<Exercise>>> searchExercises({required String query, MuscleGroup? muscleGroup}) =>
      _supabaseExerciseDataSource.searchCatalog(query: query, muscleGroup: muscleGroup);

  Future<Result<VTError, Exercise>> getExercise({required String exerciseId}) =>
      _supabaseExerciseDataSource.getExercise(exerciseId: exerciseId);

  Future<Result<VTError, List<Workout>>> getWorkoutsForDate({required DateTime date}) =>
      _supabaseWorkoutDataSource.getWorkoutsInRange(from: date, to: date);

  Future<Result<VTError, List<Workout>>> getWorkoutsInRange({required DateTime from, required DateTime to}) =>
      _supabaseWorkoutDataSource.getWorkoutsInRange(from: from, to: to);

  Future<Result<VTError, Workout>> createWorkout({required DateTime performedDate, String? notes}) =>
      _supabaseWorkoutDataSource.createWorkout(performedDate: performedDate, notes: notes);

  Future<Result<VTError, void>> deleteWorkout({required String workoutId}) =>
      _supabaseWorkoutDataSource.deleteWorkout(workoutId: workoutId);

  Future<Result<VTError, WorkoutExercise>> addWorkoutExercise({required String workoutId, required String exerciseId}) =>
      _supabaseWorkoutDataSource.addWorkoutExercise(workoutId: workoutId, exerciseId: exerciseId);

  Future<Result<VTError, void>> removeWorkoutExercise({required String workoutExerciseId}) =>
      _supabaseWorkoutDataSource.removeWorkoutExercise(workoutExerciseId: workoutExerciseId);

  Future<Result<VTError, WorkoutSet>> logSet({required String workoutExerciseId, required int reps, required double weightKg}) =>
      _supabaseWorkoutDataSource.logSet(workoutExerciseId: workoutExerciseId, reps: reps, weightKg: weightKg);

  Future<Result<VTError, WorkoutSet>> updateSet({required String setId, required int reps, required double weightKg}) =>
      _supabaseWorkoutDataSource.updateSet(setId: setId, reps: reps, weightKg: weightKg);

  Future<Result<VTError, void>> deleteSet({required String setId}) => _supabaseWorkoutDataSource.deleteSet(setId: setId);
}
