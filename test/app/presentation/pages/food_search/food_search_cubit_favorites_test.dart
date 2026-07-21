import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_tab.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  MockGetRecentlyLoggedFoodsUseCase stubbedRecentFoods() {
    final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
    when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => const Success(<FoodLogEntry>[]));
    return getRecentlyLoggedFoodsUseCase;
  }

  setUpAll(() {
    registerFallbackValue(FoodFactory.build());
  });

  MockGetFavoriteFoodsUseCase stubbedFavorites(List<Food> favorites) {
    final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
    when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => Success(favorites));
    return getFavoriteFoodsUseCase;
  }

  MockGetRecentSearchesUseCase stubbedRecents([List<String> recentSearches = const []]) {
    final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
    when(getRecentSearchesUseCase.call).thenReturn(recentSearches);
    return getRecentSearchesUseCase;
  }

  MockAddRecentSearchUseCase stubbedAddRecent() {
    final addRecentSearchUseCase = MockAddRecentSearchUseCase();
    when(() => addRecentSearchUseCase(query: any(named: 'query'))).thenAnswer((_) async => const []);
    return addRecentSearchUseCase;
  }

  test('starts with no search and no favorites', () {
    final cubit = CubitsFactories.buildFoodSearchCubit(getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(), getRecentSearchesUseCase: stubbedRecents());

    expect(cubit.state.results, isNull);
    expect(cubit.state.favorites, isEmpty);
  });

  blocTest<FoodSearchCubit, FoodSearchState>(
    'onInit lands the recent searches immediately, then the favorites once they are fetched',
    build: () => CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(['banana']),
      addRecentSearchUseCase: stubbedAddRecent(),
      getFavoriteFoodsUseCase: stubbedFavorites([FoodFactory.build(name: 'Iogurte')]),
    ),
    act: (cubit) => cubit.onInit(),
    expect: () => [
      isA<FoodSearchState>().having((state) => state.recentSearches, 'recentSearches', ['banana']).having((state) => state.favorites, 'favorites', isEmpty),
      isA<FoodSearchState>()
          .having((state) => state.favorites.map((food) => food.name), 'favorites', ['Iogurte'])
          .having((state) => state.results, 'results', isNull),
    ],
  );

  test('switching tabs keeps the search results and the favorites', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      searchFoodsUseCase: searchFoodsUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([FoodFactory.build(id: 'old', name: 'Iogurte')]),
    );

    await cubit.loadFavorites();
    await cubit.search(query: 'banana');

    cubit.changeTab(FoodSearchTab.favorites);
    expect(cubit.state.tab, FoodSearchTab.favorites);
    expect(cubit.state.results, hasLength(1));

    cubit.changeTab(FoodSearchTab.search);
    expect(cubit.state.results, hasLength(1));
    expect(cubit.state.favorites, hasLength(1));
  });

  test('clearing the query drops the results but keeps the favorites and the tab', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      searchFoodsUseCase: searchFoodsUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([FoodFactory.build(name: 'Iogurte')]),
    );

    await cubit.loadFavorites();
    await cubit.search(query: 'banana');
    expect(cubit.state.results, hasLength(1));

    await cubit.search(query: '  ');

    expect(cubit.state.results, isNull);
    expect(cubit.state.favorites, hasLength(1));
    expect(cubit.state.tab, FoodSearchTab.search);
  });

  test('favoriting a catalog food adds it to the favorites, newest first', () async {
    final food = FoodFactory.build(name: 'Frango');
    final favoriteFoodUseCase = MockFavoriteFoodUseCase();
    when(() => favoriteFoodUseCase(food: food)).thenAnswer((_) async => Success(food));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      favoriteFoodUseCase: favoriteFoodUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([FoodFactory.build(id: 'old', name: 'Iogurte')]),
    );

    await cubit.loadFavorites();
    await cubit.toggleFavorite(food: food);

    expect(cubit.state.favorites.map((favorite) => favorite.name), ['Frango', 'Iogurte']);
    expect(cubit.state.isFavorite(food), isTrue);
  });

  test('favoriting an Open Food Facts result swaps the saved copy into the results, so its heart fills', () async {
    final offFood = FoodFactory.build(id: null, name: 'Aveia');
    final savedFood = FoodFactory.build(id: 'saved-1', name: 'Aveia');
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    when(() => searchFoodsUseCase(query: 'aveia')).thenAnswer((_) async => Success([offFood]));
    final favoriteFoodUseCase = MockFavoriteFoodUseCase();
    when(() => favoriteFoodUseCase(food: offFood)).thenAnswer((_) async => Success(savedFood));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      searchFoodsUseCase: searchFoodsUseCase,
      favoriteFoodUseCase: favoriteFoodUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([]),
    );

    await cubit.search(query: 'aveia');
    expect(cubit.state.isFavorite(cubit.state.results!.single), isFalse);

    await cubit.toggleFavorite(food: offFood);

    expect(cubit.state.results!.single.id, 'saved-1');
    expect(cubit.state.isFavorite(cubit.state.results!.single), isTrue);
  });

  test('un-hearting an Open Food Facts result while its save is still in flight settles the server once the id exists', () async {
    final offFood = FoodFactory.build(id: null, name: 'Aveia');
    final savedFood = FoodFactory.build(id: 'saved-1', name: 'Aveia');
    final favoriteFoodUseCase = MockFavoriteFoodUseCase();
    when(() => favoriteFoodUseCase(food: offFood)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return Success(savedFood);
    });
    final unfavoriteFoodUseCase = MockUnfavoriteFoodUseCase();
    when(() => unfavoriteFoodUseCase(foodId: 'saved-1')).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      favoriteFoodUseCase: favoriteFoodUseCase,
      unfavoriteFoodUseCase: unfavoriteFoodUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([]),
    );

    await cubit.loadFavorites();
    final pendingFavorite = cubit.toggleFavorite(food: offFood);
    expect(cubit.state.isFavorite(offFood), isTrue);

    await cubit.toggleFavorite(food: offFood);
    expect(cubit.state.favorites, isEmpty);

    await pendingFavorite;

    expect(cubit.state.favorites, isEmpty);
    verify(() => unfavoriteFoodUseCase(foodId: 'saved-1')).called(1);
  });

  test('unfavoriting removes it from the favorites', () async {
    final food = FoodFactory.build(name: 'Iogurte');
    final unfavoriteFoodUseCase = MockUnfavoriteFoodUseCase();
    when(() => unfavoriteFoodUseCase(foodId: 'food-1')).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      unfavoriteFoodUseCase: unfavoriteFoodUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([food]),
    );

    await cubit.loadFavorites();
    expect(cubit.state.isFavorite(food), isTrue);

    await cubit.toggleFavorite(food: food);

    expect(cubit.state.favorites, isEmpty);
    expect(cubit.state.isFavorite(food), isFalse);
  });

  test('a failed favorite leaves the favorites untouched', () async {
    final food = FoodFactory.build(name: 'Frango');
    final favoriteFoodUseCase = MockFavoriteFoodUseCase();
    when(() => favoriteFoodUseCase(food: food)).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final cubit = CubitsFactories.buildFoodSearchCubit(
      getRecentlyLoggedFoodsUseCase: stubbedRecentFoods(),
      getRecentSearchesUseCase: stubbedRecents(),
      addRecentSearchUseCase: stubbedAddRecent(),
      favoriteFoodUseCase: favoriteFoodUseCase,
      getFavoriteFoodsUseCase: stubbedFavorites([]),
    );

    await cubit.loadFavorites();
    await cubit.toggleFavorite(food: food);

    expect(cubit.state.favorites, isEmpty);
  });
}
