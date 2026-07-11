import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FoodFactory.build());
    registerFallbackValue(MealType.breakfast);
    registerFallbackValue(DateTime(2000));
  });

  test('logs the food directly when it already has an id', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildLogFoodUseCase(dietRepository: dietRepository);
    final food = FoodFactory.build();
    final loggedDate = DateTime(2026, 7, 11);
    final foodLog = FoodLogFactory.build();
    when(
      () => dietRepository.logFood(foodId: 'food-1', loggedDate: loggedDate, mealType: MealType.lunch, quantityGrams: 120),
    ).thenAnswer((_) async => Success(foodLog));

    final result = await useCase(food: food, loggedDate: loggedDate, mealType: MealType.lunch, quantityGrams: 120);

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, foodLog);
    }
    verifyNever(() => dietRepository.saveFood(food: any(named: 'food')));
  });

  test('saves the food first when it has no id yet, then logs it', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildLogFoodUseCase(dietRepository: dietRepository);
    final unsavedFood = FoodFactory.build(id: null);
    final savedFood = FoodFactory.build(id: 'food-2');
    final loggedDate = DateTime(2026, 7, 11);
    final foodLog = FoodLogFactory.build(foodId: 'food-2');
    when(() => dietRepository.saveFood(food: unsavedFood)).thenAnswer((_) async => Success(savedFood));
    when(
      () => dietRepository.logFood(foodId: 'food-2', loggedDate: loggedDate, mealType: MealType.snack, quantityGrams: 50),
    ).thenAnswer((_) async => Success(foodLog));

    final result = await useCase(food: unsavedFood, loggedDate: loggedDate, mealType: MealType.snack, quantityGrams: 50);

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, foodLog);
    }
  });

  test('does not attempt to log when saving the food fails', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildLogFoodUseCase(dietRepository: dietRepository);
    final unsavedFood = FoodFactory.build(id: null);
    const error = VTError(message: 'could not save food');
    when(() => dietRepository.saveFood(food: unsavedFood)).thenAnswer((_) async => const Failure(error));

    final result = await useCase(food: unsavedFood, loggedDate: DateTime(2026, 7, 11), mealType: MealType.breakfast, quantityGrams: 100);

    switch (result) {
      case Failure(error: final resultError):
        expect(resultError, error);
      case Success():
        fail('expected Failure, got Success');
    }
    verifyNever(
      () => dietRepository.logFood(
        foodId: any(named: 'foodId'),
        loggedDate: any(named: 'loggedDate'),
        mealType: any(named: 'mealType'),
        quantityGrams: any(named: 'quantityGrams'),
      ),
    );
  });
}
