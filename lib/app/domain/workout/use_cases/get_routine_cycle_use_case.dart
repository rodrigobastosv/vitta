import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';

class GetRoutineCycleUseCase {
  GetRoutineCycleUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, RoutineCycle>> call() => _workoutRepository.getRoutineCycle();
}
