import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/domain/diet/use_cases/create_recipe_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';

class RecipeFormCubit extends PresentationCubit<RecipeFormState, RecipeFormPresentationEvent> {
  RecipeFormCubit({required this._createRecipeUseCase, required this._getAppSettingsUseCase}) : super(const RecipeFormState());

  final CreateRecipeUseCase _createRecipeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  void nameChanged(String name) => emit(state.copyWith(draft: state.draft.copyWith(name: name)));

  void addIngredient(RecipeIngredient ingredient) =>
      emit(state.copyWith(draft: state.draft.copyWith(ingredients: [...state.draft.ingredients, ingredient])));

  void removeIngredientAt(int index) => emit(
    state.copyWith(
      draft: state.draft.copyWith(ingredients: [...state.draft.ingredients]..removeAt(index)),
    ),
  );

  Future<void> submit() async {
    if (!state.draft.isComplete) {
      emitPresentation(RecipeFormIncomplete());
      return;
    }
    emitPresentation(RecipeFormShowLoading());
    final createdResult = await _createRecipeUseCase(draft: state.draft);
    emitPresentation(RecipeFormHideLoading());
    createdResult.when((error) => emitPresentation(RecipeFormError(message: error.message)), (recipe) {
      Log.action('recipe_created', data: {'ingredients': state.draft.ingredients.length});
      emitPresentation(RecipeCreated(recipe: recipe));
    });
  }
}
