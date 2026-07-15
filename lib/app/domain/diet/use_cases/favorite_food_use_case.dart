import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class FavoriteFoodUseCase {
  FavoriteFoodUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  /// Returns the persisted food, which is what the caller favourited: a food
  /// straight out of an Open Food Facts search has no `id` yet, so it is saved
  /// into the shared catalog first, the same save-then-act step [LogFoodUseCase]
  /// does before logging.
  Future<Result<VTError, Food>> call({required Food food}) async {
    final savedFoodResult = food.id == null ? await _dietRepository.saveFood(food: food) : Success<VTError, Food>(food);
    final savedFood = savedFoodResult.when((_) => null, (value) => value);
    if (savedFood == null) {
      return savedFoodResult;
    }
    final favoritedResult = await _dietRepository.addFavoriteFood(foodId: savedFood.id!);
    return favoritedResult.when(Failure.new, (_) => Success(savedFood));
  }
}
