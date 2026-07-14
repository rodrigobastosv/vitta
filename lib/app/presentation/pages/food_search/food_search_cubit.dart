import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_nutrition_label_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/upload_food_image_use_case.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';

class FoodSearchCubit extends PresentationCubit<FoodSearchState, FoodSearchPresentationEvent> {
  FoodSearchCubit({
    required this._searchFoodsUseCase,
    required this._logFoodUseCase,
    required this._getAppSettingsUseCase,
    required this._uploadFoodImageUseCase,
    required this._scanNutritionLabelUseCase,
  }) : super(const FoodSearchState());

  final SearchFoodsUseCase _searchFoodsUseCase;
  final LogFoodUseCase _logFoodUseCase;
  final GetAppSettingsUseCase _getAppSettingsUseCase;
  final UploadFoodImageUseCase _uploadFoodImageUseCase;
  final ScanNutritionLabelUseCase _scanNutritionLabelUseCase;

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  Future<void> search({required String query}) async {
    if (query.trim().isEmpty) {
      emit(const FoodSearchState());
      return;
    }
    emitPresentation(FoodSearchShowLoading());
    final foodsResult = await _searchFoodsUseCase(query: query);
    emitPresentation(FoodSearchHideLoading());
    foodsResult.when(
      (error) => emitPresentation(FoodSearchError(message: error.message)),
      (value) => emit(FoodSearchState(results: value)),
    );
  }

  Future<Result<VTError, FoodLog>> logFood({
    required Food food,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
  }) async {
    final loggedResult = await _logFoodUseCase(
      food: food,
      loggedDate: DateTime(loggedDate.year, loggedDate.month, loggedDate.day),
      mealType: mealType,
      quantityGrams: quantityGrams,
    );
    loggedResult.when((_) {}, (_) {
      Log.action('food_logged', data: {'food': food.name, 'meal': mealType.wireValue});
      emitPresentation(FoodLogged(foodName: food.name, mealType: mealType));
    });
    return loggedResult;
  }

  Future<Result<VTError, String>> uploadFoodImage({required Uint8List bytes, required String fileExtension}) =>
      _uploadFoodImageUseCase(bytes: bytes, fileExtension: fileExtension);

  Future<Result<VTError, ScannedNutritionFacts>> scanNutritionLabel({required String imagePath}) =>
      _scanNutritionLabelUseCase(imagePath: imagePath);
}
