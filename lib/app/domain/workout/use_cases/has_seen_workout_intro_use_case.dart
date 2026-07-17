import 'package:vitta/app/data/workout/workout_repository.dart';

class HasSeenWorkoutIntroUseCase {
  HasSeenWorkoutIntroUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  bool call() => _workoutRepository.hasSeenIntro();
}
