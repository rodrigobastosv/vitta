import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  MockAddRecentSearchUseCase stubbedAddRecentSearch() {
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    when(() => addRecentSearchUseCase(query: any(named: 'query'))).thenAnswer((_) async => const <String>[]);
    return addRecentSearchUseCase;
  }

  MockGetRecentlyLoggedFoodsUseCase stubbedRecentFoods() {
    final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
    when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<FoodLogEntry>[]));
    return getRecentlyLoggedFoodsUseCase;
  }

  MockAddRecentSearchUseCase stubbedAddRecent() {
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    when(() => addRecentSearchUseCase(query: any(named: 'query'))).thenAnswer((_) async => const []);
    return addRecentSearchUseCase;
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<String, Object?>{});
  });

  test('search with a blank query stays idle without hitting the use case', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    final cubit = CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: stubbedAddRecent(),
    );

    await cubit.search(query: '   ');

    expect(cubit.state, const AddFoodState());
    verifyNever(() => searchFoodsUseCase(query: any(named: 'query')));
  });

  blocTest<AddFoodCubit, AddFoodState>(
    'emits a loaded state when the search succeeds',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
      return CubitsFactories.buildAddFoodCubit(
        getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
        searchFoodsUseCase: searchFoodsUseCase,
        addRecentSearchUseCase: stubbedAddRecent(),
      );
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expect: () => [predicate<AddFoodState>((state) => state.results != null)],
  );

  blocPresentationTest<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
    'shows then hides loading while search runs',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
      return CubitsFactories.buildAddFoodCubit(
        getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
        searchFoodsUseCase: searchFoodsUseCase,
        addRecentSearchUseCase: stubbedAddRecent(),
      );
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expectPresentation: () => [isA<AddFoodShowLoading>(), isA<AddFoodHideLoading>()],
  );

  blocPresentationTest<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
    'emits AddFoodError when the search fails',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildAddFoodCubit(
        getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
        searchFoodsUseCase: searchFoodsUseCase,
        addRecentSearchUseCase: stubbedAddRecent(),
      );
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expectPresentation: () => [isA<AddFoodShowLoading>(), isA<AddFoodHideLoading>(), isA<AddFoodError>()],
  );

  test('logFood delegates to the use case with the given past date and meal', () async {
    final logFoodUseCase = MockLogFoodUseCase();
    final cubit = CubitsFactories.buildAddFoodCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), logFoodUseCase: logFoodUseCase);
    final food = FoodFactory.build();
    final foodLog = FoodLogFactory.build();
    final pastDate = DateTime(2026, 7, 10);
    when(() => logFoodUseCase(food: food, loggedDate: pastDate, mealType: .dinner, quantityGrams: 250)).thenAnswer((_) async => Success(foodLog));

    final loggedResult = await cubit.logFood(food: food, loggedDate: pastDate, mealType: .dinner, quantityGrams: 250);

    loggedResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, foodLog));
    verify(() => logFoodUseCase(food: food, loggedDate: pastDate, mealType: .dinner, quantityGrams: 250)).called(1);
  });

  test('logFood logs a food_logged user action on success', () async {
    final loggingService = useMockLog();
    final logFoodUseCase = MockLogFoodUseCase();
    final cubit = CubitsFactories.buildAddFoodCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), logFoodUseCase: logFoodUseCase);
    final food = FoodFactory.build();
    when(
      () => logFoodUseCase(food: food, loggedDate: DateTime(2026, 7, 10), mealType: .dinner, quantityGrams: 250),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));

    await cubit.logFood(food: food, loggedDate: DateTime(2026, 7, 10), mealType: .dinner, quantityGrams: 250);

    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, [
      'food_logged',
      {'food': food.name, 'meal': 'dinner'},
    ]);
  });

  blocPresentationTest<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
    'emits FoodLogged when the log succeeds',
    build: () {
      final logFoodUseCase = MockLogFoodUseCase();
      when(
        () => logFoodUseCase(
          food: FoodFactory.build(),
          loggedDate: any(named: 'loggedDate'),
          mealType: .dinner,
          quantityGrams: 250,
        ),
      ).thenAnswer((_) async => Success(FoodLogFactory.build()));
      return CubitsFactories.buildAddFoodCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), logFoodUseCase: logFoodUseCase);
    },
    act: (cubit) => cubit.logFood(food: FoodFactory.build(), loggedDate: DateTime(2026, 7, 10), mealType: .dinner, quantityGrams: 250),
    expectPresentation: () => [
      isA<FoodLogged>().having((event) => event.foodName, 'foodName', 'Banana').having((event) => event.mealType, 'mealType', MealType.dinner),
    ],
  );

  blocPresentationTest<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
    'does not emit FoodLogged when the log fails',
    build: () {
      final logFoodUseCase = MockLogFoodUseCase();
      when(
        () => logFoodUseCase(
          food: FoodFactory.build(),
          loggedDate: any(named: 'loggedDate'),
          mealType: .dinner,
          quantityGrams: 250,
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildAddFoodCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), logFoodUseCase: logFoodUseCase);
    },
    act: (cubit) => cubit.logFood(food: FoodFactory.build(), loggedDate: DateTime(2026, 7, 10), mealType: .dinner, quantityGrams: 250),
    expectPresentation: () => <AddFoodPresentationEvent>[],
  );

  test('typing searches on its own, once the keystrokes stop', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: any(named: 'query'))).thenAnswer((_) async => Success([FoodFactory.build()]));
    final cubit = CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: stubbedAddRecentSearch(),
    );

    cubit
      ..queryChanged('ban')
      ..queryChanged('bana')
      ..queryChanged('banana');

    verifyNever(() => searchFoodsUseCase(query: any(named: 'query')));

    await Future<void>.delayed(const Duration(milliseconds: 500));

    verify(() => searchFoodsUseCase(query: 'banana')).called(1);
    await cubit.close();
  });

  test('a one-letter query never reaches the network', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    final cubit = CubitsFactories.buildAddFoodCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), searchFoodsUseCase: searchFoodsUseCase);

    cubit.queryChanged('b');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    verifyNever(() => searchFoodsUseCase(query: any(named: 'query')));
    await cubit.close();
  });
}
