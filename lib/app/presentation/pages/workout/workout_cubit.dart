import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/use_cases/add_exercise_to_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routine_cycle_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_workouts_for_date_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/log_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/remove_workout_exercise_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/start_workout_from_routine_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/update_set_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/workout/workout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

class WorkoutCubit extends PresentationCubit<WorkoutState, WorkoutPresentationEvent> {
  WorkoutCubit({
    required this._getWorkoutsForDateUseCase,
    required this._addExerciseToWorkoutUseCase,
    required this._removeWorkoutExerciseUseCase,
    required this._logSetUseCase,
    required this._updateSetUseCase,
    required this._deleteSetUseCase,
    required this._deleteWorkoutUseCase,
    required this._getRoutineCycleUseCase,
    required this._startWorkoutFromRoutineUseCase,
    required this._getAppSettingsUseCase,
  }) : super(WorkoutState(date: _today(), workouts: const []));

  final GetWorkoutsForDateUseCase _getWorkoutsForDateUseCase;
  final AddExerciseToWorkoutUseCase _addExerciseToWorkoutUseCase;
  final RemoveWorkoutExerciseUseCase _removeWorkoutExerciseUseCase;
  final LogSetUseCase _logSetUseCase;
  final UpdateSetUseCase _updateSetUseCase;
  final DeleteSetUseCase _deleteSetUseCase;
  final DeleteWorkoutUseCase _deleteWorkoutUseCase;
  final GetRoutineCycleUseCase _getRoutineCycleUseCase;
  final StartWorkoutFromRoutineUseCase _startWorkoutFromRoutineUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => loadDate(state.date);

  Future<void> goToDate(DateTime date) => loadDate(date);

  Future<void> loadDate(DateTime date) async {
    emitPresentation(WorkoutShowLoading());
    final workoutsResult = await _getWorkoutsForDateUseCase(date: date);
    emitPresentation(WorkoutHideLoading());
    workoutsResult.when(
      (error) => emitPresentation(WorkoutError(message: error.message, date: date)),
      (value) => emit(state.copyWith(date: date, workouts: value)),
    );
    await _loadCycle();
  }

  /// The cycle is loaded alongside the day but never blocks it: a failure here
  /// leaves `state.cycle` empty, which just means the next-routine card doesn't
  /// appear. Surfacing an error dialog over a day that loaded fine would be
  /// worse than quietly hiding a suggestion.
  Future<void> _loadCycle() async {
    final cycleResult = await _getRoutineCycleUseCase();
    cycleResult.when((_) {}, (value) => emit(state.copyWith(cycle: value)));
  }

  Future<void> startRoutine(Routine routine) async {
    // Guarded here as well as in the page: a workout can only be started on
    // the day it happens, and the write is what must not be possible - not
    // just the button.
    if (!state.isToday) {
      return;
    }
    emitPresentation(WorkoutShowLoading());
    final startedResult = await _startWorkoutFromRoutineUseCase(routine: routine, date: state.date);
    emitPresentation(WorkoutHideLoading());
    await startedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action('workout_started_from_routine', data: {'routine_id': routine.id});
      return loadDate(state.date);
    });
  }

  Future<void> addExercise(Exercise exercise) async {
    final addedResult = await _addExerciseToWorkoutUseCase(date: state.date, exerciseId: exercise.id, workoutId: state.workout?.id);
    await addedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action('workout_exercise_added', data: {'exercise_id': exercise.id});
      return loadDate(state.date);
    });
  }

  Future<void> removeExercise({required String workoutExerciseId}) async {
    final removedResult = await _removeWorkoutExerciseUseCase(workoutExerciseId: workoutExerciseId);
    await removedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action('workout_exercise_removed');
      return loadDate(state.date);
    });
  }

  /// Returns its `Result` rather than emitting an error, so the sheet that
  /// captures reps/load can show the failure inline and pop on success - the
  /// same split `DietCubit.updateLog` uses.
  Future<Result<VTError, void>> logSet({required String workoutExerciseId, required int reps, required double weightKg}) async {
    final loggedResult = await _logSetUseCase(workoutExerciseId: workoutExerciseId, reps: reps, weightKg: weightKg);
    final error = loggedResult.when((error) => error, (_) => null);
    if (error != null) {
      return Failure(error);
    }
    Log.action('workout_set_logged', data: {'reps': reps, 'weight_kg': weightKg});
    await loadDate(state.date);
    return const Success(null);
  }

  Future<Result<VTError, void>> updateSet({required String setId, required int reps, required double weightKg}) async {
    final updatedResult = await _updateSetUseCase(setId: setId, reps: reps, weightKg: weightKg);
    final error = updatedResult.when((error) => error, (_) => null);
    if (error != null) {
      return Failure(error);
    }
    Log.action('workout_set_updated', data: {'reps': reps, 'weight_kg': weightKg});
    await loadDate(state.date);
    return const Success(null);
  }

  Future<void> deleteSet({required String setId}) async {
    final deletedResult = await _deleteSetUseCase(setId: setId);
    await deletedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action('workout_set_deleted');
      return loadDate(state.date);
    });
  }

  Future<void> deleteWorkout({required String workoutId}) async {
    final deletedResult = await _deleteWorkoutUseCase(workoutId: workoutId);
    await deletedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action('workout_deleted');
      return loadDate(state.date);
    });
  }

  void _emitError(VTError error) => emitPresentation(WorkoutError(message: error.message, date: state.date));
}
