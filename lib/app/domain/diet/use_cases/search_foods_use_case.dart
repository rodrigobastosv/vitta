import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class SearchFoodsUseCase {
  SearchFoodsUseCase({required DietRepository dietRepository}) : _dietRepository = dietRepository;

  final DietRepository _dietRepository;

  Future<Result<VTError, List<Food>>> call({required String query}) => _dietRepository.searchFoods(query: query);
}
