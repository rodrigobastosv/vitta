import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  late MockSearchFoodsUseCase searchFoodsUseCase;
  late MockLogFoodUseCase logFoodUseCase;

  setUp(() {
    searchFoodsUseCase = MockSearchFoodsUseCase();
    logFoodUseCase = MockLogFoodUseCase();
  });

  test('search with a blank query stays idle without hitting the use case', () async {
    final cubit = buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase, logFoodUseCase: logFoodUseCase);

    await cubit.search(query: '   ');

    expect(cubit.state, const FoodSearchIdle());
    verifyNever(() => searchFoodsUseCase(query: any(named: 'query')));
  });

  blocTest<FoodSearchCubit, FoodSearchState>(
    'emits [FoodSearchLoading, FoodSearchLoaded] when the search succeeds',
    setUp: () {
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([buildFood()]));
    },
    build: () => buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase, logFoodUseCase: logFoodUseCase),
    act: (cubit) => cubit.search(query: 'banana'),
    expect: () => [const FoodSearchLoading(), isA<FoodSearchLoaded>()],
  );

  blocTest<FoodSearchCubit, FoodSearchState>(
    'emits [FoodSearchLoading, FoodSearchError] when the search fails',
    setUp: () {
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    },
    build: () => buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase, logFoodUseCase: logFoodUseCase),
    act: (cubit) => cubit.search(query: 'banana'),
    expect: () => [const FoodSearchLoading(), const FoodSearchError(message: 'boom')],
  );

  test('logFood delegates to the use case with today logged for the given meal', () async {
    final cubit = buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase, logFoodUseCase: logFoodUseCase);
    final food = buildFood();
    final foodLog = buildFoodLog();
    when(
      () => logFoodUseCase(food: food, loggedDate: any(named: 'loggedDate'), mealType: MealType.dinner, quantityGrams: 250),
    ).thenAnswer((_) async => Success(foodLog));

    final result = await cubit.logFood(food: food, mealType: MealType.dinner, quantityGrams: 250);

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, foodLog);
    }
  });
}
