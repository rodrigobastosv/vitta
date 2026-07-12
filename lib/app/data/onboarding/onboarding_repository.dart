import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';

class OnboardingRepository {
  OnboardingRepository({required OnboardingLocalDataSource onboardingLocalDataSource})
    : _onboardingLocalDataSource = onboardingLocalDataSource;

  final OnboardingLocalDataSource _onboardingLocalDataSource;

  bool hasSeenOnboarding() => _onboardingLocalDataSource.hasSeenOnboarding();

  Future<void> completeOnboarding() => _onboardingLocalDataSource.markOnboardingSeen();
}
