import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

/// Adds an exercise to the day's workout, pre-filled with the sets from the
/// last time it was trained (issue #95). It's the standalone twin of
/// `StartWorkoutFromRoutineUseCase`, which does the same seeding for a whole
/// routine at once - the same two calls (`getLastSetsByExercise` +
/// `logSetsBulk`), here for one exercise.
///
/// The seeded sets are **recorded, not suggested**: the user adjusts what
/// changed and deletes what they didn't do. An exercise never trained before
/// starts empty. A failed `logSetsBulk` can leave the exercise added but empty
/// - an ordinary editable row, the same partial-write trade the routine path
/// documents, since there's no RPC to make it one transaction.
class AddExerciseToWorkoutUseCase {
  AddExerciseToWorkoutUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, WorkoutExercise>> call({required DateTime date, required String exerciseId, String? workoutId}) async {
    // Fetched before creating anything: at this point the exercise isn't in
    // today's workout yet, so the newest hit is genuinely the previous session
    // - no exclude-today needed. Failing here shouldn't leave a fresh empty
    // workout behind either.
    final lastSetsResult = await _workoutRepository.getLastSetsByExercise(exerciseIds: [exerciseId]);
    final lastSetsError = lastSetsResult.when((error) => error, (_) => null);
    if (lastSetsError != null) {
      return Failure(lastSetsError);
    }
    final lastSets = lastSetsResult.when((_) => const <String, List<WorkoutSet>>{}, (value) => value)[exerciseId];

    final targetWorkoutIdResult = switch (workoutId) {
      final String id => Success<VTError, String>(id),
      null => await _createWorkout(date),
    };
    final workoutIdError = targetWorkoutIdResult.when((error) => error, (_) => null);
    if (workoutIdError != null) {
      return Failure(workoutIdError);
    }
    final targetWorkoutId = targetWorkoutIdResult.when((_) => '', (value) => value);

    final addedResult = await _workoutRepository.addWorkoutExercise(workoutId: targetWorkoutId, exerciseId: exerciseId);
    final addedError = addedResult.when((error) => error, (_) => null);
    if (addedError != null) {
      return Failure(addedError);
    }
    final added = addedResult.when((_) => null, (value) => value)!;

    if (lastSets == null || lastSets.isEmpty) {
      return Success(added);
    }
    final filledResult = await _workoutRepository.logSetsBulk(setsByWorkoutExercise: {added.id: lastSets});
    return filledResult.when(Failure.new, (_) => Success(added));
  }

  Future<Result<VTError, String>> _createWorkout(DateTime date) async {
    final workoutResult = await _workoutRepository.createWorkout(performedDate: date);
    return workoutResult.when(Failure.new, (value) => Success(value.id));
  }
}
