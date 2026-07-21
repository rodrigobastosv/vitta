import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(MacroGoals.defaultGoals));

  blocTest<OnboardingCubit, OnboardingState>(
    'delegates to the use case when completing onboarding',
    build: () {
      final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
      when(completeOnboardingUseCase.call).thenAnswer((_) async {});
      return CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase);
    },
    act: (cubit) => cubit.completeOnboarding(),
    expect: () => <OnboardingState>[],
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'skipping the goals step persists nothing, so the defaults stay untouched',
    build: () {
      final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
      final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
      when(completeOnboardingUseCase.call).thenAnswer((_) async {});
      when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
      return CubitsFactories.buildOnboardingCubit(
        completeOnboardingUseCase: completeOnboardingUseCase,
        saveMacroGoalsUseCase: saveMacroGoalsUseCase,
      );
    },
    act: (cubit) => cubit.completeOnboarding(),
    verify: (cubit) => expect(cubit.state.goalsAccepted, isFalse),
  );

  test('accepting the goals step saves the calorie target scaled into macros', () async {
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildOnboardingCubit(
      completeOnboardingUseCase: completeOnboardingUseCase,
      saveMacroGoalsUseCase: saveMacroGoalsUseCase,
    );

    cubit
      ..calorieGoalChanged(2400)
      ..acceptGoals();
    await cubit.completeOnboarding();

    final saved = verify(() => saveMacroGoalsUseCase(captureAny())).captured.single as MacroGoals;
    expect(saved.calorieGoal.round(), 2400);
  });

  test('a skipped goals step never reaches the use case', () async {
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildOnboardingCubit(
      completeOnboardingUseCase: completeOnboardingUseCase,
      saveMacroGoalsUseCase: saveMacroGoalsUseCase,
    );

    cubit.calorieGoalChanged(2400);
    await cubit.completeOnboarding();

    verifyNever(() => saveMacroGoalsUseCase(any()));
  });
}
