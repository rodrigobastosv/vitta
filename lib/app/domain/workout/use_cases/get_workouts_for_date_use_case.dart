import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';

class GetWorkoutsForDateUseCase {
  GetWorkoutsForDateUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, List<Workout>>> call({required DateTime date}) => _workoutRepository.getWorkoutsForDate(date: date);
}
