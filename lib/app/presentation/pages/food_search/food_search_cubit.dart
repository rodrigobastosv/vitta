import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';

class FoodSearchCubit extends PresentationCubit<FoodSearchState, FoodSearchPresentationEvent> {
  FoodSearchCubit({required SearchFoodsUseCase searchFoodsUseCase, required LogFoodUseCase logFoodUseCase})
    : _searchFoodsUseCase = searchFoodsUseCase,
      _logFoodUseCase = logFoodUseCase,
      super(const FoodSearchIdle());

  final SearchFoodsUseCase _searchFoodsUseCase;
  final LogFoodUseCase _logFoodUseCase;

  Future<void> search({required String query}) async {
    if (query.trim().isEmpty) {
      emit(const FoodSearchIdle());
      return;
    }
    emitPresentation(const FoodSearchShowLoading());
    final foods = await _searchFoodsUseCase(query: query);
    emitPresentation(const FoodSearchHideLoading());
    switch (foods) {
      case Failure(:final error):
        emit(FoodSearchError(message: error.message));
      case Success(:final value):
        emit(FoodSearchLoaded(results: value));
    }
  }

  Future<Result<VTError, FoodLog>> logFood({
    required Food food,
    required MealType mealType,
    required double quantityGrams,
  }) {
    final now = DateTime.now();
    return _logFoodUseCase(
      food: food,
      loggedDate: DateTime(now.year, now.month, now.day),
      mealType: mealType,
      quantityGrams: quantityGrams,
    );
  }
}
