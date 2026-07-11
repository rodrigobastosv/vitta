import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  late MockDietRepository dietRepository;
  late SearchFoodsUseCase useCase;

  setUp(() {
    dietRepository = MockDietRepository();
    useCase = SearchFoodsUseCase(dietRepository: dietRepository);
  });

  test('returns foods from the repository search', () async {
    final foods = [buildFood()];
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
