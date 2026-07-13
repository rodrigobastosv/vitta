import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the macro goals from the repository', () {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildGetMacroGoalsUseCase(dietRepository: dietRepository);
    final macroGoals = MacroGoalsFactory.build();
    when(dietRepository.getMacroGoals).thenReturn(macroGoals);

    expect(useCase(), macroGoals);
  });
}
