import 'package:vitta/app/data/onboarding/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  CompleteOnboardingUseCase({required this._onboardingRepository});

  final OnboardingRepository _onboardingRepository;

  Future<void> call() => _onboardingRepository.completeOnboarding();
}
