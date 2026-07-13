import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';

import '../../../../factories/entities/sleep_log_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('logs sleep for the given bed/wake times and quality rating', () async {
    final sleepRepository = MockSleepRepository();
    final useCase = UseCasesFactories.buildLogSleepUseCase(sleepRepository: sleepRepository);
    final bedTime = DateTime(2026, 7, 10, 22, 30);
    final wakeTime = DateTime(2026, 7, 11, 6, 45);
    final sleepLog = SleepLogFactory.build();
    when(() => sleepRepository.logSleep(bedTime: bedTime, wakeTime: wakeTime, qualityRating: 4)).thenAnswer((_) async => Success(sleepLog));

    final loggedResult = await useCase(bedTime: bedTime, wakeTime: wakeTime, qualityRating: 4);

    loggedResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, sleepLog));
  });

  test('propagates a repository failure', () async {
    final sleepRepository = MockSleepRepository();
    final useCase = UseCasesFactories.buildLogSleepUseCase(sleepRepository: sleepRepository);
    final bedTime = DateTime(2026, 7, 10, 22, 30);
    final wakeTime = DateTime(2026, 7, 11, 6, 45);
    const error = VTError(message: 'network error');
    when(() => sleepRepository.logSleep(bedTime: bedTime, wakeTime: wakeTime)).thenAnswer((_) async => const Failure(error));

    final loggedResult = await useCase(bedTime: bedTime, wakeTime: wakeTime);

    loggedResult.when((resultError) => expect(resultError, error), (_) => fail('expected Failure, got Success'));
  });
}
