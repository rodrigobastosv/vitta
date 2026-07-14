import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/update_food_log_request.dart';
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
      final barcode = food.barcode;
      if (barcode != null) {
        final existingRow = await _supabaseService.from(.foods).select().eq('barcode', barcode).maybeSingle();
        if (existingRow != null) {
          return Success(Food.fromMap(existingRow));
        }
      }
      final request = CreateFoodRequest(food: food, userId: _userId);
      final row = await _supabaseService.from(.foods).insert(request.toJson()).select().single();
      return Success(Food.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to save food "${food.name}"', cause: error));
    }
  }

  Future<Result<VTError, List<Food>>> searchCatalog({required String query}) async {
    try {
      final rows = await _supabaseService.from(.foods).select().ilike('name', '%$query%').order('times_logged', ascending: false).order('name').limit(20);
      return Success(rows.map(Food.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to search food catalog', cause: error));
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
      final row = await _supabaseService.from(.foodLogs).insert(request.toJson()).select().single();
      return Success(FoodLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log food', cause: error));
    }
  }

  Future<Result<VTError, List<FoodLogEntry>>> getDailyLog({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from(.foodLogs)
          .select('*, ${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .eq('logged_date', date.toIso8601String().split('T').first)
          .order('created_at');
      return Success(rows.map(FoodLogEntry.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load food logs for $date', cause: error));
    }
  }

  Future<Result<VTError, FoodLog>> updateFoodLog({
    required String logId,
    required MealType mealType,
    required double quantityGrams,
  }) async {
    try {
      final request = UpdateFoodLogRequest(mealType: mealType, quantityGrams: quantityGrams);
      final row = await _supabaseService
          .from(.foodLogs)
          .update(request.toJson())
          .eq('id', logId)
          .eq('user_id', _userId)
          .select()
          .single();
      return Success(FoodLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update food log $logId', cause: error));
    }
  }

  Future<Result<VTError, void>> deleteFoodLog({required String logId}) async {
    try {
      await _supabaseService.from(.foodLogs).delete().eq('id', logId).eq('user_id', _userId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete food log $logId', cause: error));
    }
  }

  Future<Result<VTError, List<FoodLogEntry>>> getMonthlyLog({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.foodLogs)
          .select('*, ${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .gte('logged_date', from.toIso8601String().split('T').first)
          .lte('logged_date', to.toIso8601String().split('T').first)
          .order('created_at');
      return Success(rows.map(FoodLogEntry.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load monthly food logs', cause: error));
    }
  }

  Future<Result<VTError, String>> uploadFoodImage({required Uint8List bytes, required String fileExtension}) async {
    try {
      final path = '$_userId/${DateTime.now().microsecondsSinceEpoch}.$fileExtension';
      final storage = _supabaseService.storage(.foodImages);
      await storage.uploadBinary(path, bytes);
      return Success(storage.getPublicUrl(path));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to upload food image', cause: error));
    }
  }
}
