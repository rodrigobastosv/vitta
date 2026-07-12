import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';

class OnboardingRepository {
  OnboardingRepository({required this._onboardingLocalDataSource});

  final OnboardingLocalDataSource _onboardingLocalDataSource;

  bool hasSeenOnboarding() => _onboardingLocalDataSource.hasSeenOnboarding();

  Future<void> completeOnboarding() => _onboardingLocalDataSource.markOnboardingSeen();
}
