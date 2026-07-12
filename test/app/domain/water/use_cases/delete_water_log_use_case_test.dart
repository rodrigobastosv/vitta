import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates deletion to the repository', () async {
    final waterRepository = MockWaterRepository();
    final useCase = UseCasesFactories.buildDeleteWaterLogUseCase(waterRepository: waterRepository);
    when(() => waterRepository.deleteWaterLog(logId: 'log-1')).thenAnswer((_) async => const Success(null));

    final result = await useCase(logId: 'log-1');

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success():
        break;
    }
    verify(() => waterRepository.deleteWaterLog(logId: 'log-1')).called(1);
  });
}
