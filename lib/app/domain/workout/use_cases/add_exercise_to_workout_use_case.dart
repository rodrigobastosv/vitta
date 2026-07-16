import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class AddExerciseToWorkoutUseCase {
  AddExerciseToWorkoutUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, WorkoutExercise>> call({required DateTime date, required String exerciseId, String? workoutId}) async {
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
    return addedResult.when((error) => Future.value(Failure(error)), (added) async {
      if (lastSets == null || lastSets.isEmpty) {
        return Success(added);
      }
      final filledResult = await _workoutRepository.logSetsBulk(setsByWorkoutExercise: {added.id: lastSets});
      return filledResult.when(Failure.new, (_) => Success(added));
    });
  }

  Future<Result<VTError, String>> _createWorkout(DateTime date) async {
    final workoutResult = await _workoutRepository.createWorkout(performedDate: date);
    return workoutResult.when(Failure.new, (value) => Success(value.id));
  }
}
