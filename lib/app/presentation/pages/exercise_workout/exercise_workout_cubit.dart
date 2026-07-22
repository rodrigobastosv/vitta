import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/log_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/set_workout_exercise_completed_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/update_set_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_extra.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/exercise_workout_state.dart';

class ExerciseWorkoutCubit extends PresentationCubit<ExerciseWorkoutState, ExerciseWorkoutPresentationEvent> {
  ExerciseWorkoutCubit({
    required ExerciseWorkoutExtra extra,
    required this._logSetUseCase,
    required this._updateSetUseCase,
    required this._deleteSetUseCase,
    required this._setWorkoutExerciseCompletedUseCase,
  }) : super(ExerciseWorkoutState(workoutExercise: extra.workoutExercise));

  final LogSetUseCase _logSetUseCase;
  final UpdateSetUseCase _updateSetUseCase;
  final DeleteSetUseCase _deleteSetUseCase;
  final SetWorkoutExerciseCompletedUseCase _setWorkoutExerciseCompletedUseCase;

  Future<Result<VTError, void>> logSet({required SetInput input}) async {
    final isCardio = state.workoutExercise.isCardio;
    final loggedResult = await _logSetUseCase(workoutExerciseId: state.workoutExercise.id, input: input);
    return loggedResult.when(Failure.new, (set) {
      emit(state.copyWith(workoutExercise: _withSets([...state.workoutExercise.sets, set])));
      // No rest to time after a cardio effort: there is no next set to rest for.
      if (!isCardio) {
        emitPresentation(ExerciseWorkoutSetLogged());
      }
      return const Success(null);
    });
  }

  Future<void> repeatLastSet() async {
    final last = state.workoutExercise.sets.lastOrNull;
    if (last == null || state.workoutExercise.isCardio) {
      return;
    }
    final repeatedResult = await logSet(input: SetInput.fromSet(last));
    repeatedResult.when((error) => emitPresentation(ExerciseWorkoutError(message: error.message)), (_) {});
  }

  Future<Result<VTError, void>> updateSet({required String setId, required SetInput input}) async {
    final updatedResult = await _updateSetUseCase(setId: setId, input: input);
    return updatedResult.when(Failure.new, (updated) {
      emit(state.copyWith(workoutExercise: _withSets([for (final set in state.workoutExercise.sets) set.id == setId ? updated : set])));
      return const Success(null);
    });
  }

  Future<void> deleteSet({required String setId}) async {
    final deletedResult = await _deleteSetUseCase(setId: setId);
    deletedResult.when(
      (error) => emitPresentation(ExerciseWorkoutError(message: error.message)),
      (_) => emit(
        state.copyWith(
          workoutExercise: _withSets([
            for (final set in state.workoutExercise.sets)
              if (set.id != setId) set,
          ]),
        ),
      ),
    );
  }

  Future<bool> setCompleted({required bool completed}) async {
    if (completed && !state.canComplete) {
      return false;
    }
    emitPresentation(ExerciseWorkoutShowLoading());
    final updatedResult = await _setWorkoutExerciseCompletedUseCase(workoutExerciseId: state.workoutExercise.id, completed: completed);
    emitPresentation(ExerciseWorkoutHideLoading());
    return updatedResult.when(
      (error) {
        emitPresentation(ExerciseWorkoutError(message: error.message));
        return false;
      },
      (updated) {
        emit(state.copyWith(workoutExercise: updated));
        return true;
      },
    );
  }

  WorkoutExercise _withSets(List<WorkoutSet> sets) => WorkoutExercise(
    id: state.workoutExercise.id,
    exercise: state.workoutExercise.exercise,
    position: state.workoutExercise.position,
    sets: sets,
    completedAt: state.workoutExercise.completedAt,
  );
}
