import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class SupabaseDietDataSource {
  SupabaseDietDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  Future<Result<VTError, Food>> saveFood({required Food food}) async {
    try {
      final request = CreateFoodRequest(food: food, userId: _userId);
      final row = await _supabaseService.from('foods').insert(request.toJson()).select().single();
      return Success(Food.fromMap(row));
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
      return Success(FoodLog.fromMap(row));
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
      return Success(rows.map(FoodLogEntry.fromMap).toList());
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

  Future<Result<VTError, Set<DateTime>>> getLoggedDates({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from('food_logs')
          .select('logged_date')
          .eq('user_id', _userId)
          .gte('logged_date', from.toIso8601String().split('T').first)
          .lte('logged_date', to.toIso8601String().split('T').first);
      return Success(rows.map((row) => DateTime.parse(row['logged_date'] as String)).toSet());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load logged dates', cause: error));
    }
  }
}
