import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/use_cases/favorite_food_use_case.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FoodFactory.build());
  });

  test('a food that is already in the catalog is favorited by its id, without being saved again', () async {
    final dietRepository = MockDietRepository();
    final food = FoodFactory.build();
    when(() => dietRepository.addFavoriteFood(foodId: 'food-1')).thenAnswer((_) async => const Success(null));
    final useCase = FavoriteFoodUseCase(dietRepository: dietRepository);

    final favoritedResult = await useCase(food: food);

    expect(favoritedResult.when((error) => null, (value) => value), food);
    verifyNever(() => dietRepository.saveFood(food: any(named: 'food')));
  });

  test('a food with no id is saved into the catalog first, then favorited by the id that comes back', () async {
    final dietRepository = MockDietRepository();
    final offFood = FoodFactory.build(id: null);
    final savedFood = FoodFactory.build(id: 'saved-1');
    when(() => dietRepository.saveFood(food: offFood)).thenAnswer((_) async => Success(savedFood));
    when(() => dietRepository.addFavoriteFood(foodId: 'saved-1')).thenAnswer((_) async => const Success(null));
    final useCase = FavoriteFoodUseCase(dietRepository: dietRepository);

    final favoritedResult = await useCase(food: offFood);

    expect(favoritedResult.when((error) => null, (value) => value), savedFood);
    verify(() => dietRepository.addFavoriteFood(foodId: 'saved-1')).called(1);
  });

  test('a failed save never reaches the favorite call', () async {
    final dietRepository = MockDietRepository();
    final offFood = FoodFactory.build(id: null);
    when(() => dietRepository.saveFood(food: offFood)).thenAnswer((_) async => const Failure(VTError(message: 'save boom')));
    final useCase = FavoriteFoodUseCase(dietRepository: dietRepository);

    final favoritedResult = await useCase(food: offFood);

    expect(favoritedResult.when((error) => error.message, (_) => null), 'save boom');
    verifyNever(() => dietRepository.addFavoriteFood(foodId: any(named: 'foodId')));
  });

  test('forwards a failure from the favorite call itself', () async {
    final dietRepository = MockDietRepository();
    final food = FoodFactory.build();
    when(() => dietRepository.addFavoriteFood(foodId: 'food-1')).thenAnswer((_) async => const Failure(VTError(message: 'fav boom')));
    final useCase = FavoriteFoodUseCase(dietRepository: dietRepository);

    final favoritedResult = await useCase(food: food);

    expect(favoritedResult.when((error) => error.message, (_) => null), 'fav boom');
  });
}
