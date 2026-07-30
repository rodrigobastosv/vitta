import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';

class GetRecentMealsUseCase {
  GetRecentMealsUseCase({required this._dietRepository});

  static const int defaultLimit = 8;

  final DietRepository _dietRepository;

  Future<Result<VTError, List<RecentMeal>>> call({int limit = defaultLimit}) => _dietRepository.getRecentMeals(limit: limit);
}
