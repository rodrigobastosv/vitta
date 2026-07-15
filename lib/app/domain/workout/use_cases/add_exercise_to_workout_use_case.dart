import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class AddExerciseToWorkoutUseCase {
  AddExerciseToWorkoutUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, WorkoutExercise>> call({required DateTime date, required String exerciseId, String? workoutId}) async {
    final targetWorkoutIdResult = switch (workoutId) {
      final String id => Success<VTError, String>(id),
      null => await _createWorkout(date),
    };
    return targetWorkoutIdResult.when(
      (error) => Future.value(Failure(error)),
      (value) => _workoutRepository.addWorkoutExercise(workoutId: value, exerciseId: exerciseId),
    );
  }

  Future<Result<VTError, String>> _createWorkout(DateTime date) async {
    final workoutResult = await _workoutRepository.createWorkout(performedDate: date);
    return workoutResult.when(Failure.new, (value) => Success(value.id));
  }
}
