import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates deletion to the repository', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildDeleteFoodLogUseCase(dietRepository: dietRepository);
    when(() => dietRepository.deleteFoodLog(logId: 'log-1')).thenAnswer((_) async => const Success(null));

    final result = await useCase(logId: 'log-1');

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success():
        break;
    }
    verify(() => dietRepository.deleteFoodLog(logId: 'log-1')).called(1);
  });
}
