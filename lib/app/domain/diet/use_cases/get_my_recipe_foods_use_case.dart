import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

// The recipes this user created, as the plain catalog rows they are, so they
// can be logged from the same tile every other food uses. GetRecipesUseCase is
// the other half - it carries the ingredients, which listing them does not need.
class GetMyRecipeFoodsUseCase {
  GetMyRecipeFoodsUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, List<Food>>> call() => _dietRepository.getMyRecipeFoods();
}
