import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/datasources/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase_diet_datasource.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class DietRepository {
  DietRepository({required this._openFoodFactsDataSource, required this._supabaseDietDataSource});

  final OpenFoodFactsDataSource _openFoodFactsDataSource;
  final SupabaseDietDataSource _supabaseDietDataSource;

  Future<Result<VTError, List<Food>>> searchFoods({required String query}) => _openFoodFactsDataSource.searchFoods(query: query);

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
}
