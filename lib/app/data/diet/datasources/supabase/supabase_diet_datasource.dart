import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/cache/wire_cache_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/diet/datasources/supabase/food_search_ranking.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/update_food_log_request.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/update_food_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class SupabaseDietDataSource {
  SupabaseDietDataSource({required this._supabaseService, required this._wireCacheService});

  final SupabaseService _supabaseService;
  final WireCacheService _wireCacheService;

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

  // Search is ranked by RELEVANCE first and popularity only within a relevance
  // tier (issue #285). It used to be a single `ilike '%query%'` ordered by
  // times_logged, which failed twice over:
  //
  //   * Unanchored matching. '%ovo%' matches prOVOlone and the Czech OVOce, and
  //     '%leite%' matches every chocolate bar labelled "ao leite", so searching
  //     for an egg returned cheese.
  //   * The popularity order was a no-op. Almost nothing in a bulk-imported
  //     catalog has ever been logged, so `times_logged desc` tied on 0 for
  //     virtually every row and the real sort was the `name asc` tiebreak -
  //     which is why "Aussie Bar Banana Walnut" outranked "Banana".
  //
  // Each tier is its own query rather than one query ordered by a CASE, because
  // PostgREST cannot express that. They run in parallel and are concatenated in
  // tier order, then deduped by id keeping the first (best) tier a row appeared
  // in - a row matching `equals` necessarily also matches `contains`, so the
  // dedupe is what makes the tiers exclusive.
  //
  // The tiers match on search_text, the accent-folded name (see schema.sql), so
  // "feijao" finds "feijão" - it found 0 of 15 such rows before. Brand is its
  // own tier and stays unfolded. The ordering itself lives in FoodSearchRanking,
  // where it can be tested.
  Future<Result<VTError, List<Food>>> searchCatalog({required String query}) async {
    final term = FoodSearchRanking.termFor(query);
    if (term.isEmpty) {
      return const Success([]);
    }
    try {
      final tiers = await Future.wait([for (final tier in FoodSearchTier.values) _tierRows(tier: tier, term: term)]);
      final ranked = FoodSearchRanking.rank(tiers, limit: _catalogSearchLimit);
      return Success(ranked.map(Food.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to search food catalog', cause: error));
    }
  }

  Future<List<Map<String, dynamic>>> _tierRows({required FoodSearchTier tier, required String term}) {
    final query = _supabaseService.from(.foods).select();
    final matched = switch (tier) {
      FoodSearchTier.equals => query.eq('search_text', term),
      FoodSearchTier.startsWith => query.like('search_text', '$term%'),
      FoodSearchTier.word => query.like('search_text', '% $term%'),
      FoodSearchTier.contains => query.like('search_text', '%$term%'),
      FoodSearchTier.brand => query.ilike('brand', '%$term%'),
    };
    return matched
        .or('source.neq.${FoodSource.recipe.wireValue},user_id.eq.$_userId')
        .order('times_logged', ascending: false)
        .order('name', ascending: true)
        .limit(_catalogSearchLimit);
  }

  static const _myFoodsLimit = 100;

  // Foods this user added to the shared catalog, not every row they own: saving
  // an Open Food Facts search result stamps it with the logger's user_id too, so
  // a bare user_id filter would list every packaged product they ever logged.
  // The source is also what tells a typed-in product from a recipe, which is a
  // foods row as well ('recipe') and is listed as its own section.
  Future<Result<VTError, List<Food>>> getMyFoods() => _myCatalogFoods(.custom, failureMessage: 'Failed to load the foods you added');

  Future<Result<VTError, List<Food>>> getMyRecipeFoods() => _myCatalogFoods(.recipe, failureMessage: 'Failed to load the recipes you created');

  Future<Result<VTError, List<Food>>> _myCatalogFoods(FoodSource source, {required String failureMessage}) async {
    try {
      final rows = await _supabaseService
          .from(.foods)
          .select()
          .eq('user_id', _userId)
          .eq('source', source.wireValue)
          .order('created_at', ascending: false)
          .limit(_myFoodsLimit);
      return Success(rows.map(Food.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: failureMessage, cause: error));
    }
  }

  Future<Result<VTError, FoodLog>> logFood({
    required String foodId,
    required DateTime loggedDate,
    required MealType mealType,
    required LoggedQuantity quantity,
  }) async {
    try {
      final request = CreateFoodLogRequest(userId: _userId, foodId: foodId, loggedDate: loggedDate, mealType: mealType, quantity: quantity);
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
            quantity: LoggedQuantity.fromLog(entry.log),
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
      await _wireCacheService.write(_dailyLogCacheKey(date), rows);
      return Success(rows.map(FoodLogEntry.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load food logs for $date', cause: error));
    }
  }

  List<FoodLogEntry>? cachedDailyLog({required DateTime date}) {
    final rows = _wireCacheService.read(_dailyLogCacheKey(date));
    return rows?.map(FoodLogEntry.fromMap).toList();
  }

  String _dailyLogCacheKey(DateTime date) => 'diet.dailyLog.$_userId.${date.toIso8601String().split('T').first}';

  Future<Result<VTError, FoodLog>> updateFoodLog({
    required String logId,
    required MealType mealType,
    required LoggedQuantity quantity,
  }) async {
    try {
      final request = UpdateFoodLogRequest(mealType: mealType, quantity: quantity);
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
