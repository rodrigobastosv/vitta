import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_function_exception_extensions.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/data/diet/datasources/supabase/requests/meal_suggestion_request.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';

class SupabaseMealSuggestionDataSource {
  SupabaseMealSuggestionDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, MealSuggestions>> suggestMeals({required MealSuggestionRequest request}) async {
    try {
      final response = await _supabaseService.invoke(.suggestMeals, body: request.toJson());
      return Success(MealSuggestions.fromMap(response.data as Map<String, dynamic>));
    } on FunctionException catch (error) {
      if (error.isPremiumRequired) {
        return Failure(PremiumRequiredError(cause: error));
      }
      return Failure(VTError(message: 'Failed to suggest meals', cause: error));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to suggest meals', cause: error));
    }
  }
}
