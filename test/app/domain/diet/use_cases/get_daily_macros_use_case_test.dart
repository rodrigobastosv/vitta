import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the daily macros for the given date', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildGetDailyMacrosUseCase(dietRepository: dietRepository);
    final date = DateTime(2026, 7, 11);
    const dailyMacros = DailyMacros(entries: []);
    when(() => dietRepository.getDailyMacros(date: date)).thenAnswer((_) async => const Success(dailyMacros));

    final dailyMacrosResult = await useCase(date: date);

    dailyMacrosResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, dailyMacros));
  });
}
