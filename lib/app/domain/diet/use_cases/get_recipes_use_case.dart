import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';

class GetRecipesUseCase {
  GetRecipesUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, List<Recipe>>> call() => _dietRepository.getRecipes();
}
