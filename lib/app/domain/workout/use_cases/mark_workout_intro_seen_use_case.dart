import 'package:vitta/app/data/workout/workout_repository.dart';

class MarkWorkoutIntroSeenUseCase {
  MarkWorkoutIntroSeenUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<void> call() => _workoutRepository.markIntroSeen();
}
