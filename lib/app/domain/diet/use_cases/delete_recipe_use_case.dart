import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';

class DeleteRecipeUseCase {
  DeleteRecipeUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({required String recipeId}) => _dietRepository.deleteRecipe(recipeId: recipeId);
}
