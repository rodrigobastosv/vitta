import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class SleepLocalDataSource {
  SleepLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _durationGoalHoursKey = 'sleep.durationGoalHours';
  static const _lastSyncedAtKey = 'sleep.lastSyncedAt';
  static const defaultDurationGoalHours = 8.0;

  double getDurationGoalHours() => _localStorageService.get<double>(_durationGoalHoursKey) ?? defaultDurationGoalHours;

  Future<void> saveDurationGoalHours(double goalHours) => _localStorageService.put(_durationGoalHoursKey, goalHours);

  DateTime? getLastSyncedAt() {
    final millis = _localStorageService.get<int>(_lastSyncedAtKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> saveLastSyncedAt(DateTime syncedAt) => _localStorageService.put(_lastSyncedAtKey, syncedAt.millisecondsSinceEpoch);
}
