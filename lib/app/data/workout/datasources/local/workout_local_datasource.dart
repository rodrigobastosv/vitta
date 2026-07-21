import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class WorkoutLocalDataSource {
  WorkoutLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _introSeenKey = 'workout.introSeen';
  static const _restSecondsKey = 'workout.restSeconds';
  static const defaultRestSeconds = 90;

  bool hasSeenIntro() => _localStorageService.get<bool>(_introSeenKey) ?? false;

  Future<void> markIntroSeen() => _localStorageService.put(_introSeenKey, true);

  int getRestSeconds() => _localStorageService.get<int>(_restSecondsKey) ?? defaultRestSeconds;

  Future<void> saveRestSeconds(int seconds) => _localStorageService.put(_restSecondsKey, seconds);
}
