import 'package:vitta/app/data/workout/workout_repository.dart';

class GetRestDurationUseCase {
  GetRestDurationUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Duration call() => Duration(seconds: _workoutRepository.getRestSeconds());
}
