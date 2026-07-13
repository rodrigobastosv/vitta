import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  test('search with a blank query stays idle without hitting the use case', () async {
    final searchFoodsUseCase = MockSearchFoodsUseCase();
    final cubit = CubitsFactories.buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase);

    await cubit.search(query: '   ');

    expect(cubit.state, const FoodSearchState());
    verifyNever(() => searchFoodsUseCase(query: any(named: 'query')));
  });

  blocTest<FoodSearchCubit, FoodSearchState>(
    'emits a loaded state when the search succeeds',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
      return CubitsFactories.buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase);
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expect: () => [predicate<FoodSearchState>((state) => state.results != null)],
  );

  blocPresentationTest<FoodSearchCubit, FoodSearchState, FoodSearchPresentationEvent>(
    'shows then hides loading while search runs',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => Success([FoodFactory.build()]));
      return CubitsFactories.buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase);
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expectPresentation: () => [isA<FoodSearchShowLoading>(), isA<FoodSearchHideLoading>()],
  );

  blocPresentationTest<FoodSearchCubit, FoodSearchState, FoodSearchPresentationEvent>(
    'emits FoodSearchError when the search fails',
    build: () {
      final searchFoodsUseCase = MockSearchFoodsUseCase();
      when(() => searchFoodsUseCase(query: 'banana')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildFoodSearchCubit(searchFoodsUseCase: searchFoodsUseCase);
    },
    act: (cubit) => cubit.search(query: 'banana'),
    expectPresentation: () => [isA<FoodSearchShowLoading>(), isA<FoodSearchHideLoading>(), isA<FoodSearchError>()],
  );

  test('logFood delegates to the use case with today logged for the given meal', () async {
    final logFoodUseCase = MockLogFoodUseCase();
    final cubit = CubitsFactories.buildFoodSearchCubit(logFoodUseCase: logFoodUseCase);
    final food = FoodFactory.build();
    final foodLog = FoodLogFactory.build();
    when(
      () => logFoodUseCase(
        food: food,
        loggedDate: any(named: 'loggedDate'),
        mealType: MealType.dinner,
        quantityGrams: 250,
      ),
    ).thenAnswer((_) async => Success(foodLog));

    final loggedResult = await cubit.logFood(food: food, mealType: MealType.dinner, quantityGrams: 250);

    loggedResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, foodLog));
  });

  test('uploadFoodImage delegates to the use case', () async {
    final uploadFoodImageUseCase = MockUploadFoodImageUseCase();
    final cubit = CubitsFactories.buildFoodSearchCubit(uploadFoodImageUseCase: uploadFoodImageUseCase);
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(
      () => uploadFoodImageUseCase(bytes: bytes, fileExtension: 'jpg'),
    ).thenAnswer((_) async => const Success('https://example.com/food.jpg'));

    final uploadResult = await cubit.uploadFoodImage(bytes: bytes, fileExtension: 'jpg');

    uploadResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, 'https://example.com/food.jpg'));
  });
}
