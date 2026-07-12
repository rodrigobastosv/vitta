import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/diet/datasources/requests/create_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/requests/create_food_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class SupabaseDietDataSource {
  SupabaseDietDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  Future<Result<VTError, Food>> saveFood({required Food food}) async {
    try {
      final request = CreateFoodRequest(food: food, userId: _userId);
      final row = await _supabaseService.from('foods').insert(request.toJson()).select().single();
      return Success(_foodFromRow(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to save food "${food.name}"', cause: error));
    }
  }

  Future<Result<VTError, FoodLog>> logFood({
    required String foodId,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
  }) async {
    try {
      final request = CreateFoodLogRequest(
        userId: _userId,
        foodId: foodId,
        loggedDate: loggedDate,
        mealType: mealType,
        quantityGrams: quantityGrams,
      );
      final row = await _supabaseService.from('food_logs').insert(request.toJson()).select().single();
      return Success(_foodLogFromRow(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log food', cause: error));
    }
  }

  Future<Result<VTError, List<FoodLogEntry>>> getDailyLog({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from('food_logs')
          .select('*, foods(*)')
          .eq('user_id', _userId)
          .eq('logged_date', date.toIso8601String().split('T').first)
          .order('created_at');
      return Success(rows.map(_foodLogEntryFromRow).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load food logs for $date', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteFoodLog({required String logId}) async {
    try {
      await _supabaseService.from('food_logs').delete().eq('id', logId).eq('user_id', _userId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete food log $logId', cause: error));
    }
  }

  Food _foodFromRow(Map<String, dynamic> row) => Food(
    id: row['id'] as String,
    name: row['name'] as String,
    brand: row['brand'] as String?,
    barcode: row['barcode'] as String?,
    source: FoodSource.fromWireValue(row['source'] as String),
    caloriesPer100g: (row['calories_per_100g'] as num).toDouble(),
    proteinPer100g: (row['protein_per_100g'] as num).toDouble(),
    carbsPer100g: (row['carbs_per_100g'] as num).toDouble(),
    fatPer100g: (row['fat_per_100g'] as num).toDouble(),
  );

  FoodLog _foodLogFromRow(Map<String, dynamic> row) => FoodLog(
    id: row['id'] as String,
    foodId: row['food_id'] as String,
    loggedDate: DateTime.parse(row['logged_date'] as String),
    mealType: MealType.fromWireValue(row['meal_type'] as String),
    quantityGrams: (row['quantity_grams'] as num).toDouble(),
  );

  FoodLogEntry _foodLogEntryFromRow(Map<String, dynamic> row) =>
      FoodLogEntry(log: _foodLogFromRow(row), food: _foodFromRow(row['foods'] as Map<String, dynamic>));
}
