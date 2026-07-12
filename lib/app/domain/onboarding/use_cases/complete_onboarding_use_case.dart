import 'package:vitta/app/data/onboarding/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase({required OnboardingRepository onboardingRepository}) : _onboardingRepository = onboardingRepository;

  final OnboardingRepository _onboardingRepository;

  Future<void> call() => _onboardingRepository.completeOnboarding();
}
