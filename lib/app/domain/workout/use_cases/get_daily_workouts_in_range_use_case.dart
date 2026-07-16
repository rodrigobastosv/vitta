import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/daily_workout.dart';

class GetDailyWorkoutsInRangeUseCase {
  GetDailyWorkoutsInRangeUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, Map<DateTime, DailyWorkout>>> call({required DateTime from, required DateTime to}) =>
      _workoutRepository.getDailyWorkoutsInRange(from: from, to: to);
}
