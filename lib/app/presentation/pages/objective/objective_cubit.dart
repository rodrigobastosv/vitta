import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/body_profile/use_cases/get_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_profile/use_cases/save_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/get_latest_body_weight_use_case.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/objective/objective_presentation_event.dart';
import 'package:vitta/app/presentation/pages/objective/objective_state.dart';

class ObjectiveCubit extends PresentationCubit<ObjectiveState, ObjectivePresentationEvent> {
  ObjectiveCubit({
    required this._getBodyProfileUseCase,
    required this._saveBodyProfileUseCase,
    required this._getLatestBodyWeightUseCase,
    required this._saveMacroGoalsUseCase,
    required this._getAppSettingsUseCase,
  }) : super(const ObjectiveState());

  final GetBodyProfileUseCase _getBodyProfileUseCase;
  final SaveBodyProfileUseCase _saveBodyProfileUseCase;
  final GetLatestBodyWeightUseCase _getLatestBodyWeightUseCase;
  final SaveMacroGoalsUseCase _saveMacroGoalsUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => load();

  Future<void> load() => withLoadingOverlay(
    () async {
      final profile = _getBodyProfileUseCase();
      final latestResult = await _getLatestBodyWeightUseCase();
      final latest = latestResult.when((_) => null, (log) => log);
      emit(
        ObjectiveState(
          objective: profile.objective,
          heightCm: profile.effectiveHeightCm,
          weightKg: latest?.weightKg ?? BodyProfile.defaultWeightKg,
          hasWeighIn: latest != null,
          isLoaded: true,
        ),
      );
    },
    showOverlay: state.isLoaded,
    showLoadingEvent: ObjectiveShowLoading(),
    hideLoadingEvent: ObjectiveHideLoading(),
  );

  void objectiveChanged(FitnessObjective objective) => emit(state.copyWith(objective: objective));

  void heightChanged(double heightCm) => emit(state.copyWith(heightCm: heightCm));

  // Saving writes both halves: the objective (so it can be switched again later,
  // and so the modality stays derivable from it) and the macro goals it derives.
  // The goals are what every other screen reads - nothing downstream learns about
  // objectives, exactly as nothing downstream learns about diet modalities.
  Future<void> saveObjective() async {
    final objective = state.objective;
    if (objective == null) {
      return;
    }
    final goals = objective.goalsFor(weightKg: state.weightKg, heightCm: state.heightCm);
    await _saveBodyProfileUseCase(state.profile);
    await _saveMacroGoalsUseCase(goals);
    Log.action(.objectiveChanged, data: {'objective': objective.wireValue, 'calories': goals.calorieGoal.round()});
    emitPresentation(ObjectiveSaved());
  }
}
