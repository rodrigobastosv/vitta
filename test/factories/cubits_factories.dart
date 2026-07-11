import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

import '../mocks/datasources_mocks.dart';
import '../mocks/use_cases_mocks.dart';

AppCubit buildAppCubit({MockSettingsLocalDataSource? settingsLocalDataSource}) {
  if (settingsLocalDataSource != null) {
    return AppCubit(settingsLocalDataSource: settingsLocalDataSource);
  }
  final dataSource = MockSettingsLocalDataSource();
  when(dataSource.getLocale).thenReturn(null);
  when(dataSource.getThemeMode).thenReturn(ThemeMode.system);
  when(() => dataSource.saveLocale(any())).thenAnswer((_) async {});
  when(() => dataSource.saveThemeMode(any())).thenAnswer((_) async {});
  return AppCubit(settingsLocalDataSource: dataSource);
}

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
