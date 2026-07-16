import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class UpdateFoodLogUseCase {
  UpdateFoodLogUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, FoodLog>> call({
    required String logId,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) => _dietRepository.updateFoodLog(logId: logId, mealType: mealType, quantityGrams: quantityGrams, quantityUnits: quantityUnits);
}
