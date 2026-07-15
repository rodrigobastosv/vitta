import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  MockGetRecentSearchesUseCase stubbedRecents([List<String> recentSearches = const []]) {
    final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
    when(getRecentSearchesUseCase.call).thenReturn(recentSearches);
    return getRecentSearchesUseCase;
  }

  // onInit loads favourites too, and that use case returns a non-nullable
  // Result a bare mock can't satisfy.
  MockGetFavoriteFoodsUseCase stubbedFavorites() {
    final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
    when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
    return getFavoriteFoodsUseCase;
  }

  test('a search that finds something is recorded, and the returned list becomes the state', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    when(() => addRecentSearchUseCase(query: 'banana')).thenAnswer((_) async => ['banana', 'frango']);
    final cubit = CubitsFactories.buildFoodSearchCubit(
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: addRecentSearchUseCase,
      getRecentSearchesUseCase: stubbedRecents(['frango']),
    );

    await cubit.search(query: 'banana');

    expect(cubit.state.recentSearches, ['banana', 'frango']);
    expect(cubit.state.query, 'banana');
    verify(() => addRecentSearchUseCase(query: 'banana')).called(1);
  });

  test('a search that finds nothing is not recorded', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'bananna')).thenAnswer((_) async => const Success([]));
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    final cubit = CubitsFactories.buildFoodSearchCubit(
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: addRecentSearchUseCase,
      getRecentSearchesUseCase: stubbedRecents(),
    );

    await cubit.search(query: 'bananna');

    expect(cubit.state.results, isEmpty);
    expect(cubit.state.recentSearches, isEmpty);
    verifyNever(() => addRecentSearchUseCase(query: any(named: 'query')));
  });

  test('a search that fails is not recorded', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'frango')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    final cubit = CubitsFactories.buildFoodSearchCubit(
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: addRecentSearchUseCase,
      getRecentSearchesUseCase: stubbedRecents(),
    );

    await cubit.search(query: 'frango');

    expect(cubit.state.recentSearches, isEmpty);
    verifyNever(() => addRecentSearchUseCase(query: any(named: 'query')));
  });

  test('clearing the query keeps the recent searches, so the list is there to tap again', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    when(() => addRecentSearchUseCase(query: 'banana')).thenAnswer((_) async => ['banana']);
    final cubit = CubitsFactories.buildFoodSearchCubit(
      searchFoodsUseCase: searchFoodsUseCase,
      addRecentSearchUseCase: addRecentSearchUseCase,
      getRecentSearchesUseCase: stubbedRecents(),
    );

    await cubit.search(query: 'banana');
    await cubit.search(query: '');

    expect(cubit.state.results, isNull);
    expect(cubit.state.recentSearches, ['banana']);
  });

  test('removing one recent search takes the updated list from the use case', () async {
    final removeRecentSearchUseCase = MockRemoveRecentSearchUseCase();
    when(() => removeRecentSearchUseCase(query: 'frango')).thenAnswer((_) async => ['banana']);
    final cubit = CubitsFactories.buildFoodSearchCubit(
      removeRecentSearchUseCase: removeRecentSearchUseCase,
      getRecentSearchesUseCase: stubbedRecents(['banana', 'frango']),
      getFavoriteFoodsUseCase: stubbedFavorites(),
    );

    cubit.onInit();
    await cubit.removeRecentSearch(query: 'frango');

    expect(cubit.state.recentSearches, ['banana']);
  });

  test('clearing empties the recent searches', () async {
    final clearRecentSearchesUseCase = MockClearRecentSearchesUseCase();
    when(clearRecentSearchesUseCase.call).thenAnswer((_) async => const []);
    final cubit = CubitsFactories.buildFoodSearchCubit(
      clearRecentSearchesUseCase: clearRecentSearchesUseCase,
      getRecentSearchesUseCase: stubbedRecents(['banana', 'frango']),
      getFavoriteFoodsUseCase: stubbedFavorites(),
    );

    cubit.onInit();
    expect(cubit.state.recentSearches, hasLength(2));

    await cubit.clearRecentSearches();

    expect(cubit.state.recentSearches, isEmpty);
  });
}
