import 'package:vitta/app/data/workout/workout_repository.dart';

class SaveRestDurationUseCase {
  SaveRestDurationUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<void> call(Duration rest) => _workoutRepository.saveRestSeconds(rest.inSeconds);
}
