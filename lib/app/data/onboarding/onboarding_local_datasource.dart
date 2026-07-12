import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class OnboardingLocalDataSource {
  OnboardingLocalDataSource({required LocalStorageService localStorageService}) : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;

  static const _seenKey = 'onboarding.seen';

  bool hasSeenOnboarding() => _localStorageService.get<bool>(_seenKey) ?? false;

  Future<void> markOnboardingSeen() => _localStorageService.put(_seenKey, true);
}
