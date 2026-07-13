import 'package:vitta/app/data/onboarding/onboarding_repository.dart';

class HasSeenOnboardingUseCase {
  HasSeenOnboardingUseCase({required this._onboardingRepository});

  final OnboardingRepository _onboardingRepository;

  bool call() => _onboardingRepository.hasSeenOnboarding();
}
