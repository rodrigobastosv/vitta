import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class WorkoutLocalDataSource {
  WorkoutLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _introSeenKey = 'workout.introSeen';
  static const _restSecondsKey = 'workout.restSeconds';
  static const _restSoundEnabledKey = 'workout.restSoundEnabled';
  static const defaultRestSeconds = 90;
  static const defaultRestSoundEnabled = true;

  bool hasSeenIntro() => _localStorageService.get<bool>(_introSeenKey) ?? false;

  Future<void> markIntroSeen() => _localStorageService.put(_introSeenKey, true);

  int getRestSeconds() => _localStorageService.get<int>(_restSecondsKey) ?? defaultRestSeconds;

  Future<void> saveRestSeconds(int seconds) => _localStorageService.put(_restSecondsKey, seconds);

  bool isRestSoundEnabled() => _localStorageService.get<bool>(_restSoundEnabledKey) ?? defaultRestSoundEnabled;

  Future<void> saveRestSoundEnabled({required bool isEnabled}) => _localStorageService.put(_restSoundEnabledKey, isEnabled);
}
