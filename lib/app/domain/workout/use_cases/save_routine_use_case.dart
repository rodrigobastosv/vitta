import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/workout/workout_repository.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/routine_draft.dart';

class SaveRoutineUseCase {
  SaveRoutineUseCase({required this._workoutRepository});

  final WorkoutRepository _workoutRepository;

  Future<Result<VTError, Routine>> call({required RoutineDraft draft, Routine? routine}) {
    final exerciseIds = [for (final exercise in draft.exercises) exercise.id];
    if (routine == null) {
      return _workoutRepository.createRoutine(name: draft.name.trim(), exerciseIds: exerciseIds);
    }
    return _workoutRepository.updateRoutine(routineId: routine.id, name: draft.name.trim(), exerciseIds: exerciseIds);
  }
}
