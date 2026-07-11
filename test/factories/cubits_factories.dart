import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

import '../mocks/datasources_mocks.dart';
import '../mocks/use_cases_mocks.dart';

abstract class CubitsFactories {
  static AppCubit buildAppCubit({MockSettingsLocalDataSource? settingsLocalDataSource}) =>
      AppCubit(settingsLocalDataSource: settingsLocalDataSource ?? MockSettingsLocalDataSource());

  static DietCubit buildDietCubit({MockGetDailyMacrosUseCase? getDailyMacrosUseCase, MockDeleteFoodLogUseCase? deleteFoodLogUseCase}) =>
      DietCubit(
        getDailyMacrosUseCase: getDailyMacrosUseCase ?? MockGetDailyMacrosUseCase(),
        deleteFoodLogUseCase: deleteFoodLogUseCase ?? MockDeleteFoodLogUseCase(),
      );

  static FoodSearchCubit buildFoodSearchCubit({MockSearchFoodsUseCase? searchFoodsUseCase, MockLogFoodUseCase? logFoodUseCase}) =>
      FoodSearchCubit(
        searchFoodsUseCase: searchFoodsUseCase ?? MockSearchFoodsUseCase(),
        logFoodUseCase: logFoodUseCase ?? MockLogFoodUseCase(),
      );
}
