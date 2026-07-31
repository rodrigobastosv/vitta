import 'package:vitta/app/data/workout/workout_repository.dart';

class GetRestSoundEnabledUseCase {
  GetRestSoundEnabledUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  bool call() => _workoutRepository.isRestSoundEnabled();
}
