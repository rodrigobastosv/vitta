import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(MacroGoals.defaultGoals));

  MockLogBodyWeightUseCase buildLoggingUseCase() {
    final logBodyWeightUseCase = MockLogBodyWeightUseCase();
    when(
      () => logBodyWeightUseCase(loggedDate: any(named: 'loggedDate'), weightKg: any(named: 'weightKg')),
    ).thenAnswer((_) async => Success(BodyWeightLogFactory.build()));
    return logBodyWeightUseCase;
  }

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
      return CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase);
    },
    act: (cubit) => cubit.completeOnboarding(),
    verify: (cubit) => expect(cubit.state.goalsAccepted, isFalse),
  );

  test('accepting the goals step saves the calorie target scaled into macros', () async {
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase);

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
    final cubit = CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase);

    cubit.calorieGoalChanged(2400);
    await cubit.completeOnboarding();

    verifyNever(() => saveMacroGoalsUseCase(any()));
  });

  test('the captured weight becomes the first body weight entry', () async {
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    final logBodyWeightUseCase = buildLoggingUseCase();
    final cubit = CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, logBodyWeightUseCase: logBodyWeightUseCase);

    cubit
      ..weightChanged(82.5)
      ..acceptBody();
    await cubit.completeOnboarding();

    verify(() => logBodyWeightUseCase(loggedDate: any(named: 'loggedDate'), weightKg: 82.5)).called(1);
  });

  test('a skipped body step logs no weight at all', () async {
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    final logBodyWeightUseCase = buildLoggingUseCase();
    final cubit = CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, logBodyWeightUseCase: logBodyWeightUseCase);

    cubit.weightChanged(82.5);
    await cubit.completeOnboarding();

    verifyNever(() => logBodyWeightUseCase(loggedDate: any(named: 'loggedDate'), weightKg: any(named: 'weightKg')));
  });

  test('a failed weight write still lets onboarding finish', () async {
    final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
    when(completeOnboardingUseCase.call).thenAnswer((_) async {});
    final logBodyWeightUseCase = MockLogBodyWeightUseCase();
    when(
      () => logBodyWeightUseCase(loggedDate: any(named: 'loggedDate'), weightKg: any(named: 'weightKg')),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase, logBodyWeightUseCase: logBodyWeightUseCase);

    cubit.acceptBody();
    await cubit.completeOnboarding();

    verify(completeOnboardingUseCase.call).called(1);
  });

  test('the objective drives the suggestion, and a slider drag overrides it', () {
    final cubit = CubitsFactories.buildOnboardingCubit()..objectiveChanged(FitnessObjective.loseWeight);
    final cutting = cubit.state.effectiveCalorieGoal;
    cubit.objectiveChanged(FitnessObjective.gainMuscle);

    expect(cubit.state.effectiveCalorieGoal, greaterThan(cutting));

    cubit.calorieGoalChanged(2400);

    expect(cubit.state.effectiveCalorieGoal, 2400);
  });

  test('changing the body after a slider drag drops back to the fresh suggestion', () {
    final cubit = CubitsFactories.buildOnboardingCubit()
      ..calorieGoalChanged(2400)
      ..weightChanged(90);

    expect(cubit.state.effectiveCalorieGoal, cubit.state.suggestedGoals.calorieGoal);
  });
}
