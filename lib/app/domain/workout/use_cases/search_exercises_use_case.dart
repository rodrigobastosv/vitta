import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class SearchExercisesUseCase {
  SearchExercisesUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, List<Exercise>>> call({required String query, MuscleGroup? muscleGroup}) =>
      _workoutRepository.searchExercises(query: query, muscleGroup: muscleGroup);
}
