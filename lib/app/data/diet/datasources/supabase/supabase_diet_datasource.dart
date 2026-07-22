import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/update_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/update_food_request.dart';
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

  Future<Result<VTError, Food>> updateFood({required Food food}) async {
    try {
      final row = await _supabaseService
          .from(.foods)
          .update(UpdateFoodRequest(food: food).toJson())
          .eq('id', food.id!)
          .eq('user_id', _userId)
          .select()
          .single();
      return Success(Food.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update food "${food.name}"', cause: error));
    }
  }

  static const _catalogSearchLimit = 20;

  // Curated generic whole foods (source 'generic', see issue #180) rank above
  // every other source: Open Food Facts is a barcode database of packaged
  // products, so a plain "banana" or "rice" was absent or buried under brands.
  // The two queries run in parallel and generic is prepended, rather than one
  // query ordered by source, because generic rows start at times_logged 0 and a
  // single `.limit(20)` ordered by popularity would truncate them out before the
  // app ever saw them. Within each tier the #56 popularity order is preserved.
  Future<Result<VTError, List<Food>>> searchCatalog({required String query}) async {
    try {
      final tiers = await Future.wait([_genericCatalogRows(query: query), _nonGenericCatalogRows(query: query)]);
      final foods = [
        for (final rows in tiers)
          for (final row in rows) Food.fromMap(row),
      ];
      return Success(foods.take(_catalogSearchLimit).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to search food catalog', cause: error));
    }
  }

  Future<List<Map<String, dynamic>>> _genericCatalogRows({required String query}) => _supabaseService
      .from(.foods)
      .select()
      .ilike('name', '%$query%')
      .eq('source', FoodSource.generic.wireValue)
      .order('times_logged', ascending: false)
      .order('name', ascending: true)
      .limit(_catalogSearchLimit);

  Future<List<Map<String, dynamic>>> _nonGenericCatalogRows({required String query}) => _supabaseService
      .from(.foods)
      .select()
      .ilike('name', '%$query%')
      .neq('source', FoodSource.generic.wireValue)
      .or('source.neq.${FoodSource.recipe.wireValue},user_id.eq.$_userId')
      .order('times_logged', ascending: false)
      .order('name', ascending: true)
      .limit(_catalogSearchLimit);

  Future<Result<VTError, FoodLog>> logFood({
    required String foodId,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) async {
    try {
      final request = CreateFoodLogRequest(
        userId: _userId,
        foodId: foodId,
        loggedDate: loggedDate,
        mealType: mealType,
        quantityGrams: quantityGrams,
        quantityUnits: quantityUnits,
      );
      final row = await _supabaseService.from(.foodLogs).insert(request.toJson()).select().single();
      return Success(FoodLog.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to log food', cause: error));
    }
  }

  Future<Result<VTError, void>> copyFoodLogs({required List<FoodLogEntry> entries, required DateTime targetDate}) async {
    try {
      final requests = [
        for (final entry in entries)
          CreateFoodLogRequest(
            userId: _userId,
            foodId: entry.log.foodId,
            loggedDate: targetDate,
            mealType: entry.log.mealType,
            quantityGrams: entry.log.quantityGrams,
            quantityUnits: entry.log.quantityUnits,
          ).toJson(),
      ];
      await _supabaseService.from(.foodLogs).insert(requests);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to copy food logs to $targetDate', cause: error));
    }
  }

  Future<Result<VTError, List<FoodLogEntry>>> getDailyLog({required DateTime date}) async {
    try {
      final rows = await _supabaseService
          .from(.foodLogs)
          .select('*, ${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .eq('logged_date', date.toIso8601String().split('T').first)
          .order('created_at', ascending: true);
      return Success(rows.map(FoodLogEntry.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load food logs for $date', cause: error));
    }
  }

  Future<Result<VTError, FoodLog>> updateFoodLog({
    required String logId,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) async {
    try {
      final request = UpdateFoodLogRequest(mealType: mealType, quantityGrams: quantityGrams, quantityUnits: quantityUnits);
      final row = await _supabaseService.from(.foodLogs).update(request.toJson()).eq('id', logId).eq('user_id', _userId).select().single();
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

  Future<Result<VTError, List<FoodLogEntry>>> getRecentEntries({required int limit}) async {
    try {
      final rows = await _supabaseService
          .from(.foodLogs)
          .select('*, ${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return Success(rows.map(FoodLogEntry.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load recently logged foods', cause: error));
    }
  }

  Future<Result<VTError, List<FoodLogEntry>>> getLogsInRange({required DateTime from, required DateTime to}) async {
    try {
      final rows = await _supabaseService
          .from(.foodLogs)
          .select('*, ${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .gte('logged_date', from.toIso8601String().split('T').first)
          .lte('logged_date', to.toIso8601String().split('T').first)
          .order('created_at', ascending: true);
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
