import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recipes_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_state.dart';

class RecipesCubit extends PresentationCubit<RecipesState, RecipesPresentationEvent> {
  RecipesCubit({
    required this._getRecipesUseCase,
    required this._deleteRecipeUseCase,
    required this._logFoodUseCase,
    required this._getAppSettingsUseCase,
  }) : super(const RecipesState(isLoaded: false));

  final GetRecipesUseCase _getRecipesUseCase;
  final DeleteRecipeUseCase _deleteRecipeUseCase;
  final LogFoodUseCase _logFoodUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  @override
  void onInit() => loadRecipes();

  Future<void> loadRecipes() async {
    final recipesResult = await withLoadingOverlay(
      _getRecipesUseCase.call,
      showOverlay: state.isLoaded,
      showLoadingEvent: RecipesShowLoading(),
      hideLoadingEvent: RecipesHideLoading(),
    );
    recipesResult.when((error) => emitPresentation(RecipesError(message: error.message)), (recipes) => emit(state.copyWith(isLoaded: true, recipes: recipes)));
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> deleteRecipe({required String recipeId}) async {
    final deletedResult = await _deleteRecipeUseCase(recipeId: recipeId);
    final error = deletedResult.when((error) => error, (_) => null);
    if (error != null) {
      emitPresentation(RecipesError(message: error.message));
      return;
    }
    Log.action('recipe_deleted');
    await loadRecipes();
  }

  Future<Result<VTError, FoodLog>> logRecipe({
    required Food recipeFood,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
  }) async {
    final loggedResult = await _logFoodUseCase(
      food: recipeFood,
      loggedDate: DateTime(loggedDate.year, loggedDate.month, loggedDate.day),
      mealType: mealType,
      quantityGrams: quantityGrams,
    );
    loggedResult.when((_) {}, (_) {
      Log.action('food_logged', data: {'food': recipeFood.name, 'meal': mealType.wireValue, 'source': 'recipe'});
      emitPresentation(RecipeLogged(recipeName: recipeFood.name, mealType: mealType));
    });
    return loggedResult;
  }
}
