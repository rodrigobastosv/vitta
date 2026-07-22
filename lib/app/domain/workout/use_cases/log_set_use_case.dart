import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class LogSetUseCase {
  LogSetUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, WorkoutSet>> call({required String workoutExerciseId, required SetInput input}) =>
      _workoutRepository.logSet(workoutExerciseId: workoutExerciseId, input: input);
}
