import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

/// The sets performed the last time each exercise was trained, keyed by
/// exercise id. Drives the "last time: 4×10 · 40kg" hint (issue #95).
///
/// [before] scopes it to sessions strictly before that day, so the hint on a
/// day's own card reflects the *previous* session rather than the sets already
/// on screen.
class GetLastSetsByExerciseUseCase {
  GetLastSetsByExerciseUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, Map<String, List<WorkoutSet>>>> call({required List<String> exerciseIds, DateTime? before}) =>
      _workoutRepository.getLastSetsByExercise(exerciseIds: exerciseIds, before: before);
}
