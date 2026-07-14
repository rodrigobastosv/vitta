import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/datasources/http/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/local/diet_goals_local_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase/supabase_diet_datasource.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class DietRepository {
  DietRepository({required this._openFoodFactsDataSource, required this._supabaseDietDataSource, required this._dietGoalsLocalDataSource});

  final OpenFoodFactsDataSource _openFoodFactsDataSource;
  final SupabaseDietDataSource _supabaseDietDataSource;
  final DietGoalsLocalDataSource _dietGoalsLocalDataSource;

  // Below this many catalog hits, the shared catalog is too thin to stand on its
  // own (e.g. a Portuguese term the OFF import barely covers), so Open Food Facts
  // is queried too and merged in. At or above it, the catalog answers alone.
  static const _sparseCatalogThreshold = 5;

  Future<Result<VTError, List<Food>>> searchFoods({required String query}) async {
    final catalogResult = await _supabaseDietDataSource.searchCatalog(query: query);
    final catalogFoods = catalogResult.when((_) => null, (foods) => foods);
    if (catalogFoods != null && catalogFoods.length >= _sparseCatalogThreshold) {
      return Success(catalogFoods);
    }
    final offResult = await _openFoodFactsDataSource.searchFoods(query: query);
    if (catalogFoods == null || catalogFoods.isEmpty) {
      return offResult;
    }
    final offFoods = offResult.when((_) => null, (foods) => foods);
    return Success(offFoods == null ? catalogFoods : _mergeByBarcode(catalogFoods, offFoods));
  }

  List<Food> _mergeByBarcode(List<Food> catalogFoods, List<Food> offFoods) {
    final catalogBarcodes = catalogFoods.map((food) => food.barcode).whereType<String>().toSet();
    return [
      ...catalogFoods,
      for (final food in offFoods)
        if (food.barcode == null || !catalogBarcodes.contains(food.barcode)) food,
    ];
  }

  Future<Result<VTError, Food>> saveFood({required Food food}) => _supabaseDietDataSource.saveFood(food: food);

  Future<Result<VTError, FoodLog>> logFood({
    required String foodId,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
  }) => _supabaseDietDataSource.logFood(foodId: foodId, loggedDate: loggedDate, mealType: mealType, quantityGrams: quantityGrams);

  Future<Result<VTError, DailyMacros>> getDailyMacros({required DateTime date}) async {
    final dailyLogResult = await _supabaseDietDataSource.getDailyLog(date: date);
    return dailyLogResult.when(Failure.new, (value) => Success(DailyMacros(entries: value)));
  }

  Future<Result<VTError, void>> deleteFoodLog({required String logId}) => _supabaseDietDataSource.deleteFoodLog(logId: logId);

  MacroGoals getMacroGoals() => _dietGoalsLocalDataSource.getGoals();

  Future<void> saveMacroGoals(MacroGoals goals) => _dietGoalsLocalDataSource.saveGoals(goals);

  Future<Result<VTError, Map<DateTime, DailyMacros>>> getMonthlyMacros({required DateTime from, required DateTime to}) async {
    final monthlyLogResult = await _supabaseDietDataSource.getMonthlyLog(from: from, to: to);
    return monthlyLogResult.when(Failure.new, (entries) => Success(_groupByDate(entries)));
  }

  Map<DateTime, DailyMacros> _groupByDate(List<FoodLogEntry> entries) {
    final entriesByDate = <DateTime, List<FoodLogEntry>>{};
    for (final entry in entries) {
      final date = entry.log.loggedDate;
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }
    return {for (final MapEntry(:key, :value) in entriesByDate.entries) key: DailyMacros(entries: value)};
  }

  Future<Result<VTError, String>> uploadFoodImage({required Uint8List bytes, required String fileExtension}) =>
      _supabaseDietDataSource.uploadFoodImage(bytes: bytes, fileExtension: fileExtension);
}
