import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class WaterLocalDataSource {
  WaterLocalDataSource({required LocalStorageService localStorageService}) : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;

  static const _dailyGoalMlKey = 'water.dailyGoalMl';
  static const defaultDailyGoalMl = 2000.0;

  double getDailyGoalMl() => _localStorageService.get<double>(_dailyGoalMlKey) ?? defaultDailyGoalMl;

  Future<void> saveDailyGoalMl(double goalMl) => _localStorageService.put(_dailyGoalMlKey, goalMl);
}
