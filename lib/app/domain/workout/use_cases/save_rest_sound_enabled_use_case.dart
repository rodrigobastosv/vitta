import 'package:vitta/app/data/workout/workout_repository.dart';

class SaveRestSoundEnabledUseCase {
  SaveRestSoundEnabledUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<void> call({required bool isEnabled}) => _workoutRepository.saveRestSoundEnabled(isEnabled: isEnabled);
}
