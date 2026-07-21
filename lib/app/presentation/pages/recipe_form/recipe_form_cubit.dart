import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/domain/diet/use_cases/save_recipe_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';

class RecipeFormCubit extends PresentationCubit<RecipeFormState, RecipeFormPresentationEvent> {
  RecipeFormCubit({
    required this._saveRecipeUseCase,
    required this._getAppSettingsUseCase,
    required this._uploadFoodImageUseCase,
    required this._imagePickerService,
    Recipe? recipe,
  }) : _recipe = recipe,
       super(RecipeFormState(draft: recipe == null ? const RecipeDraft() : RecipeDraft.fromRecipe(recipe)));

  final SaveRecipeUseCase _saveRecipeUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final UploadFoodImageUseCase _uploadFoodImageUseCase;
  final ImagePickerService _imagePickerService;
  final Recipe? _recipe;

  static const double _photoMaxWidth = 1024;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  bool get isEditing => _recipe != null;

  void nameChanged(String name) => emit(state.copyWith(draft: state.draft.copyWith(name: name)));

  void addIngredient(RecipeIngredient ingredient) => emit(state.copyWith(draft: state.draft.copyWith(ingredients: [...state.draft.ingredients, ingredient])));

  void removeIngredientAt(int index) => emit(state.copyWith(draft: state.draft.copyWith(ingredients: [...state.draft.ingredients]..removeAt(index))));

  Future<void> pickPhoto({required ImagePickerSource source}) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _photoMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emit(state.copyWith(imageBytes: pickedImage.bytes, imageExtension: pickedImage.fileExtension));
  }

  Future<void> submit() async {
    if (!state.draft.isComplete) {
      emitPresentation(RecipeFormIncomplete());
      return;
    }
    emitPresentation(RecipeFormShowLoading());
    final draftResult = await _draftWithUploadedPhoto();
    final uploadError = draftResult.when((error) => error, (_) => null);
    if (uploadError != null) {
      emitPresentation(RecipeFormHideLoading());
      emitPresentation(RecipeFormError(message: uploadError.message));
      return;
    }
    final draft = draftResult.when((_) => state.draft, (value) => value);
    final savedResult = await _saveRecipeUseCase(draft: draft, recipe: _recipe);
    emitPresentation(RecipeFormHideLoading());
    savedResult.when((error) => emitPresentation(RecipeFormError(message: error.message)), (recipe) {
      Log.action(isEditing ? 'recipe_updated' : 'recipe_created', data: {'ingredients': draft.ingredients.length});
      emitPresentation(RecipeSaved(recipe: recipe));
    });
  }

  Future<Result<VTError, RecipeDraft>> _draftWithUploadedPhoto() async {
    final imageBytes = state.imageBytes;
    if (imageBytes == null) {
      return Success(state.draft);
    }
    final imageUrlResult = await _uploadFoodImageUseCase(bytes: imageBytes, fileExtension: state.imageExtension);
    return imageUrlResult.when(Failure.new, (imageUrl) => Success(state.draft.copyWith(imageUrl: imageUrl)));
  }
}
