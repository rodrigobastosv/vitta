import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_import.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(<SleepImport>[]));

  test('delegates the import to the repository and returns the count', () async {
    final sleepRepository = MockSleepRepository();
    final useCase = UseCasesFactories.buildImportSleepFromHealthUseCase(sleepRepository: sleepRepository);
    final imports = [SleepImport(start: DateTime(2026, 7, 10, 23), end: DateTime(2026, 7, 11, 6, 30), externalId: 'ext-1')];
    when(() => sleepRepository.importSleepLogs(imports: any(named: 'imports'))).thenAnswer((_) async => const Success(1));

    final importedResult = await useCase(imports: imports);

    expect(importedResult.when((error) => -1, (count) => count), 1);
    verify(() => sleepRepository.importSleepLogs(imports: imports)).called(1);
  });
}
