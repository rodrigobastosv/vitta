import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';

import '../../../../factories/entities/sleep_log_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the recent sleep logs for the given number of days', () async {
    final sleepRepository = MockSleepRepository();
    final useCase = UseCasesFactories.buildGetRecentSleepLogsUseCase(sleepRepository: sleepRepository);
    final sleepLogs = [SleepLogFactory.build()];
    when(() => sleepRepository.getRecentSleepLogs(days: 7)).thenAnswer((_) async => Success(sleepLogs));

    final recentLogsResult = await useCase(days: 7);

    recentLogsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, sleepLogs));
  });
}
