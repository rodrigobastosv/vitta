import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/domain/onboarding/use_cases/complete_onboarding_use_case.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required CompleteOnboardingUseCase completeOnboardingUseCase})
    : _completeOnboardingUseCase = completeOnboardingUseCase,
      super(const OnboardingState());

  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  Future<void> completeOnboarding() => _completeOnboardingUseCase();
}
