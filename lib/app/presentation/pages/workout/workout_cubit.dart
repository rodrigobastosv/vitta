import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_latest_body_weight_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/use_cases/add_exercise_to_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/delete_workout_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_last_sets_by_exercise_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_routine_cycle_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/get_workouts_for_date_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/has_seen_workout_intro_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/log_set_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/mark_workout_intro_seen_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/remove_workout_exercise_use_case.dart';
import 'package:vitta/app/domain/workout/use_cases/set_workout_exercise_completed_use_case.dart';
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
    required this._setWorkoutExerciseCompletedUseCase,
    required this._getRoutineCycleUseCase,
    required this._startWorkoutFromRoutineUseCase,
    required this._getLastSetsByExerciseUseCase,
    required this._getLatestBodyWeightUseCase,
    required this._getAppSettingsUseCase,
    required this._hasSeenWorkoutIntroUseCase,
    required this._markWorkoutIntroSeenUseCase,
  }) : super(WorkoutState(isLoaded: false, date: _today(), workouts: const []));

  final GetWorkoutsForDateUseCase _getWorkoutsForDateUseCase;
  final AddExerciseToWorkoutUseCase _addExerciseToWorkoutUseCase;
  final RemoveWorkoutExerciseUseCase _removeWorkoutExerciseUseCase;
  final LogSetUseCase _logSetUseCase;
  final UpdateSetUseCase _updateSetUseCase;
  final DeleteSetUseCase _deleteSetUseCase;
  final DeleteWorkoutUseCase _deleteWorkoutUseCase;
  final SetWorkoutExerciseCompletedUseCase _setWorkoutExerciseCompletedUseCase;
  final GetRoutineCycleUseCase _getRoutineCycleUseCase;
  final StartWorkoutFromRoutineUseCase _startWorkoutFromRoutineUseCase;
  final GetLastSetsByExerciseUseCase _getLastSetsByExerciseUseCase;
  final GetLatestBodyWeightUseCase _getLatestBodyWeightUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final HasSeenWorkoutIntroUseCase _hasSeenWorkoutIntroUseCase;
  final MarkWorkoutIntroSeenUseCase _markWorkoutIntroSeenUseCase;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() {
    if (!_hasSeenWorkoutIntroUseCase()) {
      emitPresentation(WorkoutShowIntro());
    }
    loadDate(state.date);
  }

  Future<void> markIntroSeen() => _markWorkoutIntroSeenUseCase();

  Future<void> goToDate(DateTime date) => loadDate(date);

  Future<void> loadDate(DateTime date) async {
    // Every mutation reloads through here, so this is the one place that can see a
    // workout become finished. It has to be the *transition* rather than
    // state.isFinished: the first load of an already-finished day, and paging back
    // to one, both arrive at the same finished state without anything having been
    // achieved just now - and replaying the summary there would be the opposite of
    // a reward. Requiring the same date and an already-loaded state is what rules
    // both out.
    final wasUnfinishedToday = state.isLoaded && _isSameDay(state.date, date) && !state.isFinished;
    final workoutsResult = await withLoadingOverlay(
      () => _getWorkoutsForDateUseCase(date: date),
      showOverlay: state.isLoaded,
      showLoadingEvent: WorkoutShowLoading(),
      hideLoadingEvent: WorkoutHideLoading(),
    );
    workoutsResult.when(
      (error) => emitPresentation(WorkoutError(message: error.message, date: date)),
      (value) => emit(state.copyWith(isLoaded: true, date: date, workouts: value)),
    );
    await _loadCycle();
    await _loadLastSets(date);
    await _loadLatestBodyWeight();
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
    // Announced only once the previous session's sets and the body weight have
    // landed, since the summary reads its progression and its calorie estimate
    // from exactly those.
    if (wasUnfinishedToday && state.isFinished) {
      Log.action('workout_session_finished');
      emitPresentation(WorkoutSessionFinished());
    }
  }

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month && first.day == second.day;

  Future<void> _loadCycle() async {
    final cycleResult = await _getRoutineCycleUseCase();
    cycleResult.when((_) {}, (value) => emit(state.copyWith(cycle: value)));
  }

  // Non-blocking, like the cycle and last sets above: a failure just leaves the
  // bodyweight prefill unset rather than interrupting a day that loaded fine.
  Future<void> _loadLatestBodyWeight() async {
    final latestResult = await _getLatestBodyWeightUseCase();
    latestResult.when((_) {}, (value) {
      if (value != null) {
        emit(state.copyWith(latestBodyWeightKg: value.weightKg));
      }
    });
  }

  Future<void> _loadLastSets(DateTime date) async {
    final exerciseIds = [for (final exercise in state.exercises) exercise.exercise.id];
    if (exerciseIds.isEmpty) {
      return;
    }
    final lastSetsResult = await _getLastSetsByExerciseUseCase(exerciseIds: exerciseIds, before: date);
    lastSetsResult.when((_) {}, (value) => emit(state.copyWith(lastSetsByExercise: value)));
  }

  Future<void> startRoutine(Routine routine) async {
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

  Future<Result<VTError, void>> logSet({required String workoutExerciseId, required SetInput input}) async {
    final loggedResult = await _logSetUseCase(workoutExerciseId: workoutExerciseId, input: input);
    final error = loggedResult.when((error) => error, (_) => null);
    if (error != null) {
      return Failure(error);
    }
    Log.action('workout_set_logged', data: _setLogData(input));
    await loadDate(state.date);
    return const Success(null);
  }

  Future<Result<VTError, void>> updateSet({required String setId, required SetInput input}) async {
    final updatedResult = await _updateSetUseCase(setId: setId, input: input);
    final error = updatedResult.when((error) => error, (_) => null);
    if (error != null) {
      return Failure(error);
    }
    Log.action('workout_set_updated', data: _setLogData(input));
    await loadDate(state.date);
    return const Success(null);
  }

  Future<Result<VTError, void>> repeatLastSet({required WorkoutExercise workoutExercise}) async {
    final last = workoutExercise.sets.lastOrNull;
    if (last == null || workoutExercise.isCardio) {
      return const Success(null);
    }
    final loggedResult = await logSet(workoutExerciseId: workoutExercise.id, input: SetInput.fromSet(last));
    // Announced here rather than at the tap, so a repeat that no-op'd or failed
    // cannot start a rest for a set that was never written (issue #228).
    loggedResult.when((_) {}, (_) => emitPresentation(WorkoutSetRepeated(workoutExercise: workoutExercise)));
    return loggedResult;
  }

  Map<String, dynamic> _setLogData(SetInput input) => input.kind == SetKind.cardio
      ? {'duration_seconds': input.durationSeconds, 'distance_meters': input.distanceMeters}
      : {'reps': input.reps, 'weight_kg': input.weightKg};

  Future<void> setExerciseCompleted({required WorkoutExercise workoutExercise, required bool completed}) async {
    if (completed && workoutExercise.sets.isEmpty) {
      return;
    }
    final completedResult = await _setWorkoutExerciseCompletedUseCase(workoutExerciseId: workoutExercise.id, completed: completed);
    await completedResult.when((error) => Future.sync(() => _emitError(error)), (_) {
      Log.action(completed ? 'workout_exercise_completed' : 'workout_exercise_reopened');
      return loadDate(state.date);
    });
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
