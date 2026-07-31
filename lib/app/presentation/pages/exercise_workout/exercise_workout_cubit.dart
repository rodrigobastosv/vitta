import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/domain/body_profile/use_cases/get_body_profile_use_case.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/log_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/set_workout_exercise_completed_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/update_set_use_case.dart';
import 'package:vitta/app/presentation/general/body_profile_body_figure.dart';
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
    required this._getBodyProfileUseCase,
  }) : super(ExerciseWorkoutState(workoutExercise: extra.workoutExercise));

  final LogSetUseCase _logSetUseCase;
  final UpdateSetUseCase _updateSetUseCase;
  final DeleteSetUseCase _deleteSetUseCase;
  final SetWorkoutExerciseCompletedUseCase _setWorkoutExerciseCompletedUseCase;
  final GetBodyProfileUseCase _getBodyProfileUseCase;

  int _pendingSets = 0;

  VTBodyFigure get bodyFigure => _getBodyProfileUseCase().bodyFigure;

  Future<Result<VTError, void>> logSet({required SetInput input}) async {
    final isCardio = state.workoutExercise.isCardio;
    final loggedResult = await _logSetUseCase(workoutExerciseId: state.workoutExercise.id, input: input);
    return loggedResult.when(Failure.new, (set) {
      emit(state.copyWith(workoutExercise: state.workoutExercise.withSets([...state.workoutExercise.sets, set])));
      // No rest to time after a cardio effort: there is no next set to rest for.
      if (!isCardio) {
        emitPresentation(ExerciseWorkoutSetLogged());
      }
      return const Success(null);
    });
  }

  // Optimistic (issue #275), unlike logSet above: nothing is waiting on the write
  // here - the sheet path pops on the returned Result, while a repeat is one tap
  // with no form to dismiss, so the set can land in state immediately and be put
  // back if the write fails. ExerciseWorkoutSetLogged still fires only once the row
  // exists, so the rest timer keeps timing a set that was actually written.
  Future<void> repeatLastSet() async {
    final last = state.workoutExercise.sets.lastOrNull;
    if (last == null || state.workoutExercise.isCardio) {
      return;
    }
    final input = SetInput.fromSet(last);
    final previousSets = state.workoutExercise.sets;
    final pendingSet = input.asPendingSet(sequence: _pendingSets++, position: last.position + 1);
    emit(state.copyWith(workoutExercise: state.workoutExercise.withSets([...previousSets, pendingSet])));
    final loggedResult = await _logSetUseCase(workoutExerciseId: state.workoutExercise.id, input: input);
    final loggedSet = loggedResult.when((_) => null, (set) => set);
    if (loggedSet == null) {
      emit(state.copyWith(workoutExercise: state.workoutExercise.withSets(previousSets)));
      loggedResult.when((error) => emitPresentation(ExerciseWorkoutError(message: error.message)), (_) {});
      return;
    }
    emit(
      state.copyWith(
        workoutExercise: state.workoutExercise.withSets([
          for (final set in state.workoutExercise.sets)
            if (set.id == pendingSet.id) loggedSet else set,
        ]),
      ),
    );
    emitPresentation(ExerciseWorkoutSetLogged());
  }

  Future<Result<VTError, void>> updateSet({required String setId, required SetInput input}) async {
    final updatedResult = await _updateSetUseCase(setId: setId, input: input);
    return updatedResult.when(Failure.new, (updated) {
      emit(
        state.copyWith(
          workoutExercise: state.workoutExercise.withSets([for (final set in state.workoutExercise.sets) set.id == setId ? updated : set]),
        ),
      );
      return const Success(null);
    });
  }

  Future<void> deleteSet({required String setId}) async {
    final deletedResult = await _deleteSetUseCase(setId: setId);
    deletedResult.when(
      (error) => emitPresentation(ExerciseWorkoutError(message: error.message)),
      (_) => emit(
        state.copyWith(
          workoutExercise: state.workoutExercise.withSets([
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
}
