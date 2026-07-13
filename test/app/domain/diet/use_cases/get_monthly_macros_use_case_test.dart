import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the macros grouped by date for the given range', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildGetMonthlyMacrosUseCase(dietRepository: dietRepository);
    final from = DateTime(2026, 7);
    final to = DateTime(2026, 7, 31);
    final macrosByDate = {
      DateTime(2026, 7, 5): DailyMacros(entries: [FoodLogEntryFactory.build()]),
    };
    when(() => dietRepository.getMonthlyMacros(from: from, to: to)).thenAnswer((_) async => Success(macrosByDate));

    final macrosResult = await useCase(from: from, to: to);

    macrosResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, macrosByDate));
  });
}
