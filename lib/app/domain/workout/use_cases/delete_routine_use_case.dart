import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';

class DeleteRoutineUseCase {
  DeleteRoutineUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, void>> call({required String routineId}) => _workoutRepository.deleteRoutine(routineId: routineId);
}
