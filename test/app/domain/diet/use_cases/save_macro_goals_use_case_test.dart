import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates saving to the repository', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildSaveMacroGoalsUseCase(dietRepository: dietRepository);
    final macroGoals = MacroGoalsFactory.build();
    when(() => dietRepository.saveMacroGoals(macroGoals)).thenAnswer((_) async {});

    await useCase(macroGoals);

    verify(() => dietRepository.saveMacroGoals(macroGoals)).called(1);
  });
}
