import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/body_profile/use_cases/save_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/log_body_weight_use_case.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_presentation_event.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

class OnboardingCubit extends PresentationCubit<OnboardingState, OnboardingPresentationEvent> {
  OnboardingCubit({
    required this._completeOnboardingUseCase,
    required this._saveMacroGoalsUseCase,
    required this._logBodyWeightUseCase,
    required this._saveBodyProfileUseCase,
    required this._getAppSettingsUseCase,
  }) : super(const OnboardingState());

  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final SaveMacroGoalsUseCase _saveMacroGoalsUseCase;
  final LogBodyWeightUseCase _logBodyWeightUseCase;
  final SaveBodyProfileUseCase _saveBodyProfileUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  void goToStep(int step) => emit(state.copyWith(step: step.clamp(0, OnboardingState.stepCount - 1)));

  void weightChanged(double weightKg) => emit(state.withBody(weightKg: weightKg));

  void heightChanged(double heightCm) => emit(state.withBody(heightCm: heightCm));

  void objectiveChanged(FitnessObjective objective) => emit(state.withBody(objective: objective));

  void acceptBody() => emit(state.copyWith(bodyProvided: true));

  void calorieGoalChanged(double calorieGoal) => emit(state.copyWith(calorieGoal: calorieGoal));

  void acceptGoals() => emit(state.copyWith(goalsAccepted: true));

  Future<void> completeOnboarding() async {
    if (state.bodyProvided) {
      await _saveBodyProfileUseCase(BodyProfile(heightCm: state.heightCm, objective: state.objective));
      await _logFirstWeight();
    }
    if (state.goalsAccepted) {
      await _saveMacroGoalsUseCase(state.goals);
      Log.action(.onboardingGoalsSet, data: {'objective': state.objective.name, 'calories': state.effectiveCalorieGoal.round()});
    }
    await _completeOnboardingUseCase();
    Log.action(.onboardingCompleted);
  }

  // The weight captured here is the app's first body-weight entry, so it goes
  // through the ordinary LogBodyWeightUseCase - onboarding gets no write path of
  // its own. A failure is deliberately swallowed rather than toasted or retried:
  // it is a remote write on the one screen whose job is to get the user in, and
  // the same weight is one tap away on the body weight page. Onboarding has to
  // finish either way, or a user with no connection could never leave it.
  Future<void> _logFirstWeight() async {
    final today = DateTime.now();
    final loggedResult = await _logBodyWeightUseCase(loggedDate: DateTime(today.year, today.month, today.day), weightKg: state.weightKg);
    loggedResult.when((_) {}, (_) => Log.action(.onboardingWeightLogged, data: {'weight_kg': state.weightKg}));
  }
}
