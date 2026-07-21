import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_progression.dart';
import 'package:vitta/app/domain/workout/use_cases/get_exercise_progression_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_presentation_event.dart';
import 'package:vitta/app/presentation/pages/exercise_progression/exercise_progression_state.dart';

class ExerciseProgressionCubit extends PresentationCubit<ExerciseProgressionState, ExerciseProgressionPresentationEvent> {
  ExerciseProgressionCubit({required this._getExerciseProgressionUseCase, required this._getAppSettingsUseCase, required Exercise exercise})
    : super(
        ExerciseProgressionState(
          exercise: exercise,
          progression: const ExerciseProgression(points: []),
        ),
      );

  final GetExerciseProgressionUseCase _getExerciseProgressionUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => load();

  Future<void> load() async {
    emitPresentation(ExerciseProgressionShowLoading());
    final progressionResult = await _getExerciseProgressionUseCase(exerciseId: state.exercise.id);
    progressionResult.when(
      (error) => emitPresentation(ExerciseProgressionError(message: error.message)),
      (progression) => emit(state.copyWith(progression: progression)),
    );
    emitPresentation(ExerciseProgressionHideLoading());
  }
}
