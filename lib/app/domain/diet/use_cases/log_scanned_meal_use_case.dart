import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

class LogScannedMealUseCase {
  LogScannedMealUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({required List<ScannedMealLogItem> items, required DateTime loggedDate, required MealType mealType}) async {
    for (final logItem in items) {
      final savedFoodResult = await _dietRepository.saveFood(food: logItem.item.toFood());
      final saveError = savedFoodResult.when((error) => error, (_) => null);
      if (saveError != null) {
        return Failure(saveError);
      }
      final foodId = savedFoodResult.when((_) => null, (food) => food.id);
      final loggedResult = await _dietRepository.logFood(foodId: foodId!, loggedDate: loggedDate, mealType: mealType, quantityGrams: logItem.quantityGrams);
      final logError = loggedResult.when((error) => error, (_) => null);
      if (logError != null) {
        return Failure(logError);
      }
    }
    return const Success(null);
  }
}
