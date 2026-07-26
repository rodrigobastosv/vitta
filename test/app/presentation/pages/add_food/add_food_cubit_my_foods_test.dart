import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  MockGetRecentlyLoggedFoodsUseCase stubbedRecentFoods() {
    final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
    when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<FoodLogEntry>[]));
    return getRecentlyLoggedFoodsUseCase;
  }

  MockGetFavoriteFoodsUseCase stubbedFavorites() {
    final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
    when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
    return getFavoriteFoodsUseCase;
  }

  MockGetRecentSearchesUseCase stubbedRecents() {
    final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
    when(getRecentSearchesUseCase.call).thenReturn(const []);
    return getRecentSearchesUseCase;
  }

  MockGetMyFoodsUseCase stubbedMyFoods(List<Food> myFoods) {
    final getMyFoodsUseCase = MockGetMyFoodsUseCase();
    when(getMyFoodsUseCase.call).thenAnswer((_) async => Success(myFoods));
    return getMyFoodsUseCase;
  }

  blocTest<AddFoodCubit, AddFoodState>(
    'onInit loads the foods this user added',
    build: () => CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      getFavoriteFoodsUseCase: stubbedFavorites(),
      getMyFoodsUseCase: stubbedMyFoods([FoodFactory.build(id: 'mine-1', name: 'Pão da vovó')]),
    ),
    act: (cubit) => cubit.onInit(),
    skip: 1,
    expect: () => [
      isA<AddFoodState>().having((state) => state.myFoods.map((food) => food.name), 'myFoods', ['Pão da vovó']),
    ],
  );

  blocPresentationTest<AddFoodCubit, AddFoodState, AddFoodPresentationEvent>(
    'a failed read leaves the tab empty rather than toasting over the other two loads',
    build: () {
      final getMyFoodsUseCase = MockGetMyFoodsUseCase();
      when(getMyFoodsUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildAddFoodCubit(
        getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
        getRecentSearchesUseCase: stubbedRecents(),
        getFavoriteFoodsUseCase: stubbedFavorites(),
        getMyFoodsUseCase: getMyFoodsUseCase,
      );
    },
    act: (cubit) => cubit.onInit(),
    expectPresentation: () => [isA<AddFoodShowLoading>(), isA<AddFoodHideLoading>()],
    verify: (cubit) => expect(cubit.state.myFoods, isEmpty),
  );

  test('logging a food that was just created re-reads the list, so the new product is there', () async {
    final newProduct = FoodFactory.build(id: null, name: 'Granola caseira');
    final savedProduct = FoodFactory.build(id: 'mine-1', name: 'Granola caseira');
    final getMyFoodsUseCase = MockGetMyFoodsUseCase();
    when(getMyFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
    final logFoodUseCase = MockLogFoodUseCase();
    when(
      () => logFoodUseCase(
        food: newProduct,
        loggedDate: any(named: 'loggedDate'),
        mealType: .breakfast,
        quantity: const LoggedQuantity.weight(40),
      ),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));
    final cubit = CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      logFoodUseCase: logFoodUseCase,
      getMyFoodsUseCase: getMyFoodsUseCase,
    );

    when(getMyFoodsUseCase.call).thenAnswer((_) async => Success([savedProduct]));
    await cubit.logFood(
      food: newProduct,
      loggedDate: DateTime(2026, 7, 26),
      mealType: .breakfast,
      quantity: const LoggedQuantity.weight(40),
    );

    expect(cubit.state.myFoods, [savedProduct]);
  });

  test('logging a food that is already in the catalog does not re-read the list', () async {
    final catalogFood = FoodFactory.build(source: .openFoodFacts);
    final getMyFoodsUseCase = MockGetMyFoodsUseCase();
    when(getMyFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
    final logFoodUseCase = MockLogFoodUseCase();
    when(
      () => logFoodUseCase(
        food: catalogFood,
        loggedDate: any(named: 'loggedDate'),
        mealType: .lunch,
        quantity: const LoggedQuantity.weight(100),
      ),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));
    final cubit = CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      logFoodUseCase: logFoodUseCase,
      getMyFoodsUseCase: getMyFoodsUseCase,
    );

    await cubit.logFood(
      food: catalogFood,
      loggedDate: DateTime(2026, 7, 26),
      mealType: .lunch,
      quantity: const LoggedQuantity.weight(100),
    );

    verifyNever(getMyFoodsUseCase.call);
  });
}
