import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';

class GetExerciseProgressionUseCase {
  GetExerciseProgressionUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, ExerciseProgression>> call({required String exerciseId}) => _workoutRepository.getExerciseProgression(exerciseId: exerciseId);
}
