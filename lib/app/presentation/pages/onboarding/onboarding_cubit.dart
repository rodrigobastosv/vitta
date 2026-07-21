import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_presentation_event.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

class OnboardingCubit extends PresentationCubit<OnboardingState, OnboardingPresentationEvent> {
  OnboardingCubit({required this._completeOnboardingUseCase, required this._saveMacroGoalsUseCase}) : super(const OnboardingState());

  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final SaveMacroGoalsUseCase _saveMacroGoalsUseCase;

  void goToStep(int step) => emit(state.copyWith(step: step.clamp(0, OnboardingState.stepCount - 1)));

  void calorieGoalChanged(double calorieGoal) => emit(state.copyWith(calorieGoal: calorieGoal));

  void acceptGoals() => emit(state.copyWith(goalsAccepted: true));

  Future<void> completeOnboarding() async {
    if (state.goalsAccepted) {
      await _saveMacroGoalsUseCase(state.goals);
      Log.action('onboarding_goals_set', data: {'calories': state.calorieGoal.round()});
    }
    await _completeOnboardingUseCase();
    Log.action('onboarding_completed');
  }
}
