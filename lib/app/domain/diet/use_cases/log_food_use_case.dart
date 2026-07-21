import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class LogFoodUseCase {
  LogFoodUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, FoodLog>> call({
    required Food food,
    required DateTime loggedDate,
    required MealType mealType,
    required double quantityGrams,
    double? quantityUnits,
  }) async {
    final foodIdResult = switch (food.id) {
      final String id => Success<VTError, String>(id),
      null => await _saveFood(food),
    };
    return foodIdResult.when(
      (error) => Future.value(Failure(error)),
      (value) => _dietRepository.logFood(foodId: value, loggedDate: loggedDate, mealType: mealType, quantityGrams: quantityGrams, quantityUnits: quantityUnits),
    );
  }

  Future<Result<VTError, String>> _saveFood(Food food) async {
    final savedFoodResult = await _dietRepository.saveFood(food: food);
    return savedFoodResult.when(Failure.new, (value) => Success(value.id!));
  }
}
