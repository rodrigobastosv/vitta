import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';

class GetRecentlyLoggedFoodsUseCase {
  GetRecentlyLoggedFoodsUseCase({required this._dietRepository});

  static const int defaultLimit = 12;

  final DietRepository _dietRepository;

  Future<Result<VTError, List<FoodLogEntry>>> call({int limit = defaultLimit}) => _dietRepository.getRecentlyLoggedFoods(limit: limit);
}
