import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

// A suggested item is logged through the ordinary save-then-log path, item by
// item, exactly as a scanned one is - a suggestion is a food nobody has typed
// in yet, not a new kind of row. Sequential writes rather than a transaction,
// the SaveRecipeUseCase shape: a mid-way failure can leave an orphan catalog
// row, which is harmless.
class LogSuggestedMealUseCase {
  LogSuggestedMealUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({
    required List<SuggestedMealLogItem> items,
    required DateTime loggedDate,
    required MealType mealType,
  }) async {
    for (final logItem in items) {
      final savedFoodResult = await _dietRepository.saveFood(food: logItem.food);
      final saveError = savedFoodResult.when((error) => error, (_) => null);
      if (saveError != null) {
        return Failure(saveError);
      }
      final foodId = savedFoodResult.when((_) => null, (food) => food.id);
      final loggedResult = await _dietRepository.logFood(
        foodId: foodId!,
        loggedDate: loggedDate,
        mealType: mealType,
        quantity: LoggedQuantity.weight(logItem.quantityGrams),
      );
      final logError = loggedResult.when((error) => error, (_) => null);
      if (logError != null) {
        return Failure(logError);
      }
    }
    return const Success(null);
  }
}
