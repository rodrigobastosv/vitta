import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class WorkoutLocalDataSource {
  WorkoutLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _introSeenKey = 'workout.introSeen';

  bool hasSeenIntro() => _localStorageService.get<bool>(_introSeenKey) ?? false;

  Future<void> markIntroSeen() => _localStorageService.put(_introSeenKey, true);
}
