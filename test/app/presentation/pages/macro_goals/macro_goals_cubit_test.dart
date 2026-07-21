import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/macro_goals_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MacroGoalsFactory.build());
  });

  test('loads the persisted goals on construction', () {
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    final persistedGoals = MacroGoalsFactory.build(proteinGoalGrams: 180);
    when(getMacroGoalsUseCase.call).thenReturn(persistedGoals);

    final cubit = CubitsFactories.buildMacroGoalsCubit(getMacroGoalsUseCase: getMacroGoalsUseCase);

    expect(cubit.state, persistedGoals);
  });

  blocTest<MacroGoalsCubit, MacroGoals>(
    'emits the new goals when saveGoals is called',
    build: () {
      final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
      when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
      final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
      when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildMacroGoalsCubit(getMacroGoalsUseCase: getMacroGoalsUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase);
    },
    act: (cubit) => cubit.saveGoals(MacroGoalsFactory.build(proteinGoalGrams: 180)),
    expect: () => [MacroGoalsFactory.build(proteinGoalGrams: 180)],
  );

  test('persists the new goals when saveGoals is called', () async {
    final getMacroGoalsUseCase = MockGetMacroGoalsUseCase();
    when(getMacroGoalsUseCase.call).thenReturn(MacroGoalsFactory.build());
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    final newGoals = MacroGoalsFactory.build(proteinGoalGrams: 180);

    await CubitsFactories.buildMacroGoalsCubit(getMacroGoalsUseCase: getMacroGoalsUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase).saveGoals(newGoals);

    verify(() => saveMacroGoalsUseCase(newGoals)).called(1);
  });
}
