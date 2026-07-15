import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

/// Creates the day's workout from a routine: its exercises in order, each
/// pre-filled with the sets performed the last time that exercise was trained.
///
/// The pre-filled sets are a **starting point that is already recorded**, not a
/// suggestion overlay - the user adjusts the reps/load that differ and deletes
/// what they didn't do. That's the deliberate trade: it makes the common case
/// (same session as last time, maybe one number up) close to zero typing, at
/// the cost of a workout abandoned right after starting having left real-looking
/// sets behind. An exercise never trained before simply starts empty.
///
/// Like `SaveRecipeUseCase`, these are sequential writes rather than a
/// transaction - there's no RPC in the project - so a mid-way failure can leave
/// a partially built workout. That's recoverable by hand (the exercises and sets
/// are ordinary rows the user can edit or delete) and matches the existing
/// save-then-log shape.
class StartWorkoutFromRoutineUseCase {
  StartWorkoutFromRoutineUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, Workout>> call({required Routine routine, required DateTime date}) async {
    final exerciseIds = [for (final exercise in routine.exercises) exercise.id];

    final lastSetsResult = await _workoutRepository.getLastSetsByExercise(exerciseIds: exerciseIds);
    final lastSetsError = lastSetsResult.when((error) => error, (_) => null);
    if (lastSetsError != null) {
      return Failure(lastSetsError);
    }
    final lastSets = lastSetsResult.when((_) => const <String, List<WorkoutSet>>{}, (value) => value);

    final workoutResult = await _workoutRepository.createWorkout(performedDate: date, routineId: routine.id);
    final workoutError = workoutResult.when((error) => error, (_) => null);
    if (workoutError != null) {
      return Failure(workoutError);
    }
    final workoutId = workoutResult.when((_) => '', (value) => value.id);

    final setsByWorkoutExercise = <String, List<WorkoutSet>>{};
    for (final exercise in routine.exercises) {
      final addedResult = await _workoutRepository.addWorkoutExercise(workoutId: workoutId, exerciseId: exercise.id);
      final addedError = addedResult.when((error) => error, (_) => null);
      if (addedError != null) {
        return Failure(addedError);
      }
      final workoutExerciseId = addedResult.when((_) => '', (value) => value.id);
      if (lastSets[exercise.id] case final sets? when sets.isNotEmpty) {
        setsByWorkoutExercise[workoutExerciseId] = sets;
      }
    }

    final filledResult = await _workoutRepository.logSetsBulk(setsByWorkoutExercise: setsByWorkoutExercise);
    return filledResult.when(Failure.new, (_) => workoutResult);
  }
}
