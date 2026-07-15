import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class SetWorkoutExerciseCompletedUseCase {
  SetWorkoutExerciseCompletedUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, WorkoutExercise>> call({required String workoutExerciseId, required bool completed}) =>
      _workoutRepository.setWorkoutExerciseCompleted(workoutExerciseId: workoutExerciseId, completed: completed);
}
