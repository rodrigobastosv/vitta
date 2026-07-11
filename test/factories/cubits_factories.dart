import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

import '../mocks/use_cases_mocks.dart';

DietCubit buildDietCubit({
  MockGetDailyMacrosUseCase? getDailyMacrosUseCase,
  MockDeleteFoodLogUseCase? deleteFoodLogUseCase,
}) => DietCubit(
  getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
  deleteFoodLogUseCase: deleteFoodLogUseCase ?? MockDeleteFoodLogUseCase(),
);

FoodSearchCubit buildFoodSearchCubit({MockSearchFoodsUseCase? searchFoodsUseCase, MockLogFoodUseCase? logFoodUseCase}) => FoodSearchCubit(
  searchFoodsUseCase: searchFoodsUseCase ?? MockSearchFoodsUseCase(),
  logFoodUseCase: logFoodUseCase ?? MockLogFoodUseCase(),
);
