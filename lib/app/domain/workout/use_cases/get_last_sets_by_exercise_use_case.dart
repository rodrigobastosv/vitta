import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

class GetLastSetsByExerciseUseCase {
  GetLastSetsByExerciseUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, Map<String, List<WorkoutSet>>>> call({required List<String> exerciseIds, DateTime? before}) =>
      _workoutRepository.getLastSetsByExercise(exerciseIds: exerciseIds, before: before);
}
