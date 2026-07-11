import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns foods from the repository search', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildSearchFoodsUseCase(dietRepository: dietRepository);
    final foods = [FoodFactory.build()];
    when(() => dietRepository.searchFoods(query: 'banana')).thenAnswer((_) async => Success(foods));

    final result = await useCase(query: 'banana');

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, foods);
    }
  });

  test('propagates a repository failure', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildSearchFoodsUseCase(dietRepository: dietRepository);
    const error = VTError(message: 'network error');
    when(() => dietRepository.searchFoods(query: 'banana')).thenAnswer((_) async => const Failure(error));

    final result = await useCase(query: 'banana');

    switch (result) {
      case Failure(:final error):
        expect(error, const VTError(message: 'network error'));
      case Success():
        fail('expected Failure, got Success');
    }
  });
}
