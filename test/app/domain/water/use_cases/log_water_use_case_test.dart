import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';

import '../../../../factories/entities/water_log_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('logs water for the given date and amount', () async {
    final waterRepository = MockWaterRepository();
    final useCase = UseCasesFactories.buildLogWaterUseCase(waterRepository: waterRepository);
    final loggedDate = DateTime(2026, 7, 11);
    final waterLog = WaterLogFactory.build();
    when(() => waterRepository.logWater(loggedDate: loggedDate, amountMl: 250)).thenAnswer((_) async => Success(waterLog));

    final result = await useCase(loggedDate: loggedDate, amountMl: 250);

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, waterLog);
    }
  });

  test('propagates a repository failure', () async {
    final waterRepository = MockWaterRepository();
    final useCase = UseCasesFactories.buildLogWaterUseCase(waterRepository: waterRepository);
    final loggedDate = DateTime(2026, 7, 11);
    const error = VTError(message: 'network error');
    when(() => waterRepository.logWater(loggedDate: loggedDate, amountMl: 250)).thenAnswer((_) async => const Failure(error));

    final result = await useCase(loggedDate: loggedDate, amountMl: 250);

    switch (result) {
      case Failure(error: final resultError):
        expect(resultError, error);
      case Success():
        fail('expected Failure, got Success');
    }
  });
}
