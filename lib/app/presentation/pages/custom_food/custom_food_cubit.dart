import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_nutrition_label_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_state.dart';

class CustomFoodCubit extends PresentationCubit<CustomFoodState, CustomFoodPresentationEvent> {
  CustomFoodCubit({
    required this._uploadFoodImageUseCase,
    required this._scanNutritionLabelUseCase,
    required this._imagePickerService,
  }) : super(const CustomFoodState());

  final UploadFoodImageUseCase _uploadFoodImageUseCase;
  final ScanNutritionLabelUseCase _scanNutritionLabelUseCase;
  final ImagePickerService _imagePickerService;

  static const double _photoMaxWidth = 1024;
  static const double _nutritionLabelMaxWidth = 1600;

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void brandChanged(String brand) => emit(state.copyWith(brand: brand));

  void nutrientChanged({required CustomFoodNutrient nutrient, required String text}) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    final nutrients = Map.of(state.nutrients);
    if (value == null) {
      nutrients.remove(nutrient);
    } else {
      nutrients[nutrient] = value;
    }
    emit(state.copyWith(nutrients: nutrients));
  }

  Future<void> pickPhoto({required ImagePickerSource source}) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _photoMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emit(state.copyWith(imageBytes: pickedImage.bytes, imageExtension: pickedImage.fileExtension));
  }

  Future<void> scanNutritionLabel({required ImagePickerSource source}) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _nutritionLabelMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emitPresentation(CustomFoodShowLoading());
    final scannedFactsResult = await _scanNutritionLabelUseCase(imagePath: pickedImage.path);
    emitPresentation(CustomFoodHideLoading());
    scannedFactsResult.when((error) => emitPresentation(CustomFoodError(message: error.message)), _applyScannedFacts);
  }

  void _applyScannedFacts(ScannedNutritionFacts facts) {
    if (!facts.hasAnyValue) {
      emitPresentation(CustomFoodScanFoundNothing());
      return;
    }
    final nutrients = Map.of(state.nutrients);
    for (final nutrient in CustomFoodNutrient.values) {
      final scannedValue = nutrient.valueOf(facts);
      if (scannedValue != null) {
        nutrients[nutrient] = scannedValue;
      }
    }
    emit(state.copyWith(nutrients: nutrients));
  }

  Future<void> submit() async {
    if (!state.isComplete) {
      emitPresentation(CustomFoodIncomplete());
      return;
    }
    final imageBytes = state.imageBytes;
    if (imageBytes == null) {
      emitPresentation(CustomFoodReady(food: _buildFood()));
      return;
    }
    emitPresentation(CustomFoodShowLoading());
    final imageUrlResult = await _uploadFoodImageUseCase(bytes: imageBytes, fileExtension: state.imageExtension);
    emitPresentation(CustomFoodHideLoading());
    imageUrlResult.when(
      (error) => emitPresentation(CustomFoodError(message: error.message)),
      (imageUrl) => emitPresentation(CustomFoodReady(food: _buildFood(imageUrl: imageUrl))),
    );
  }

  Food _buildFood({String? imageUrl}) => Food(
    name: state.name.trim(),
    brand: state.brand.trim().isEmpty ? null : state.brand.trim(),
    source: .custom,
    caloriesPer100g: state.nutrients[CustomFoodNutrient.calories]!,
    proteinPer100g: state.nutrients[CustomFoodNutrient.protein]!,
    carbsPer100g: state.nutrients[CustomFoodNutrient.carbs]!,
    fatPer100g: state.nutrients[CustomFoodNutrient.fat]!,
    fiberPer100g: state.nutrients[CustomFoodNutrient.fiber]!,
    imageUrl: imageUrl,
  );
}
