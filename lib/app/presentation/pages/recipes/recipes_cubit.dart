import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_recipes_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_state.dart';

class RecipesCubit extends PresentationCubit<RecipesState, RecipesPresentationEvent> {
  RecipesCubit({required this._getRecipesUseCase, required this._deleteRecipeUseCase}) : super(const RecipesState(isLoaded: false));

  final GetRecipesUseCase _getRecipesUseCase;
  final DeleteRecipeUseCase _deleteRecipeUseCase;

  @override
  void onInit() => loadRecipes();

  Future<void> loadRecipes() async {
    emitPresentation(RecipesShowLoading());
    final recipesResult = await _getRecipesUseCase();
    emitPresentation(RecipesHideLoading());
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
}
