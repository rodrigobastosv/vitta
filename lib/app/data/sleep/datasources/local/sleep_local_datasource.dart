import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class SleepLocalDataSource {
  SleepLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _durationGoalHoursKey = 'sleep.durationGoalHours';
  static const defaultDurationGoalHours = 8.0;

  double getDurationGoalHours() => _localStorageService.get<double>(_durationGoalHoursKey) ?? defaultDurationGoalHours;

  Future<void> saveDurationGoalHours(double goalHours) => _localStorageService.put(_durationGoalHoursKey, goalHours);
}
