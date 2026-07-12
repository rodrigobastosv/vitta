import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_presentation_event.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

class OnboardingCubit extends PresentationCubit<OnboardingState, OnboardingPresentationEvent> {
  OnboardingCubit({required CompleteOnboardingUseCase completeOnboardingUseCase})
    : _completeOnboardingUseCase = completeOnboardingUseCase,
      super(const OnboardingState());

  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  Future<void> completeOnboarding() => _completeOnboardingUseCase();
}
