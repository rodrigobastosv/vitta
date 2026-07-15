import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';

class UnfavoriteFoodUseCase {
  UnfavoriteFoodUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, void>> call({required String foodId}) => _dietRepository.removeFavoriteFood(foodId: foodId);
}
