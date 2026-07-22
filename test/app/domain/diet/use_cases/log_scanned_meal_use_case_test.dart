import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

ScannedMealLogItem _logItem(String name, double grams) => ScannedMealLogItem(
  item: ScannedMealItem(name: name, estimatedGrams: grams, caloriesPer100g: 100, proteinPer100g: 10, carbsPer100g: 5, fatPer100g: 2),
  quantityGrams: grams,
);

void main() {
  setUpAll(() {
    registerFallbackValue(FoodFactory.build());
    registerFallbackValue(MealType.breakfast);
    registerFallbackValue(DateTime(2000));
  });

  test('saves then logs every item under the chosen meal and date', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildLogScannedMealUseCase(dietRepository: dietRepository);
    final loggedDate = DateTime(2026, 7, 19);
    when(() => dietRepository.saveFood(food: any(named: 'food'))).thenAnswer((_) async => Success(FoodFactory.build(id: 'food-9')));
    when(
      () => dietRepository.logFood(
        foodId: 'food-9',
        loggedDate: loggedDate,
        mealType: .dinner,
        quantityGrams: any(named: 'quantityGrams'),
      ),
    ).thenAnswer((_) async => Success(FoodLogFactory.build()));

    final loggedResult = await useCase(items: [_logItem('Rice', 200), _logItem('Chicken', 150)], loggedDate: loggedDate, mealType: .dinner);

    loggedResult.when((error) => fail('expected Success, got Failure($error)'), (_) {});
    verify(() => dietRepository.saveFood(food: any(named: 'food'))).called(2);
    verify(() => dietRepository.logFood(foodId: 'food-9', loggedDate: loggedDate, mealType: .dinner, quantityGrams: 200)).called(1);
    verify(() => dietRepository.logFood(foodId: 'food-9', loggedDate: loggedDate, mealType: .dinner, quantityGrams: 150)).called(1);
  });

  test('aborts without logging when saving a food fails', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildLogScannedMealUseCase(dietRepository: dietRepository);
    when(() => dietRepository.saveFood(food: any(named: 'food'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));

    final loggedResult = await useCase(items: [_logItem('Rice', 200)], loggedDate: DateTime(2026, 7, 19), mealType: .lunch);

    loggedResult.when((error) => expect(error.message, 'boom'), (_) => fail('expected Failure'));
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
