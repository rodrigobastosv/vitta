import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/create_food_favorite_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class SupabaseFoodFavoritesDataSource {
  SupabaseFoodFavoritesDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  String get _userId => _supabaseService.currentUserId;

  Future<Result<VTError, List<Food>>> getFavorites() async {
    try {
      final rows = await _supabaseService
          .from(.foodFavorites)
          .select('${SupabaseTable.foods.wireName}(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return Success([for (final row in rows) Food.fromMap(row[SupabaseTable.foods.wireName] as Map<String, dynamic>)]);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load favorite foods', cause: error));
    }
  }

  Future<Result<VTError, void>> addFavorite({required String foodId}) async {
    try {
      await _supabaseService.from(.foodFavorites).insert(CreateFoodFavoriteRequest(userId: _userId, foodId: foodId).toJson());
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to favorite food', cause: error));
    }
  }

  Future<Result<VTError, void>> removeFavorite({required String foodId}) async {
    try {
      await _supabaseService.from(.foodFavorites).delete().eq('user_id', _userId).eq('food_id', foodId);
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to unfavorite food', cause: error));
    }
  }
}
