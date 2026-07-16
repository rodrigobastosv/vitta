import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietGoalsLocalDataSource {
  DietGoalsLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _proteinGoalGramsKey = 'diet.proteinGoalGrams';
  static const _carbsGoalGramsKey = 'diet.carbsGoalGrams';
  static const _fatGoalGramsKey = 'diet.fatGoalGrams';
  static const _fiberGoalGramsKey = 'diet.fiberGoalGrams';

  MacroGoals getGoals() => MacroGoals(
    proteinGoalGrams: _localStorageService.get<double>(_proteinGoalGramsKey) ?? MacroGoals.defaultGoals.proteinGoalGrams,
    carbsGoalGrams: _localStorageService.get<double>(_carbsGoalGramsKey) ?? MacroGoals.defaultGoals.carbsGoalGrams,
    fatGoalGrams: _localStorageService.get<double>(_fatGoalGramsKey) ?? MacroGoals.defaultGoals.fatGoalGrams,
    fiberGoalGrams: _localStorageService.get<double>(_fiberGoalGramsKey) ?? MacroGoals.defaultGoals.fiberGoalGrams,
  );

  Future<void> saveGoals(MacroGoals goals) async {
    await _localStorageService.put(_proteinGoalGramsKey, goals.proteinGoalGrams);
    await _localStorageService.put(_carbsGoalGramsKey, goals.carbsGoalGrams);
    await _localStorageService.put(_fatGoalGramsKey, goals.fatGoalGrams);
    await _localStorageService.put(_fiberGoalGramsKey, goals.fiberGoalGrams);
  }
}
