import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/objective/objective_cubit.dart';
import 'package:vitta/app/presentation/pages/objective/objective_presentation_event.dart';
import 'package:vitta/app/presentation/pages/objective/objective_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MacroGoals.defaultGoals);
    registerFallbackValue(const BodyProfile());
  });

  blocTest<ObjectiveCubit, ObjectiveState>(
    'loads the stored objective and the latest weigh-in',
    build: () {
      final getBodyProfileUseCase = MockGetBodyProfileUseCase();
      when(getBodyProfileUseCase.call).thenReturn(const BodyProfile(heightCm: 180, objective: FitnessObjective.loseWeight));
      final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
      when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => Success(BodyWeightLogFactory.build(weightKg: 82)));
      return CubitsFactories.buildObjectiveCubit(getBodyProfileUseCase: getBodyProfileUseCase, getLatestBodyWeightUseCase: getLatestBodyWeightUseCase);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const ObjectiveState(objective: FitnessObjective.loseWeight, heightCm: 180, weightKg: 82, hasWeighIn: true, isLoaded: true)],
  );

  blocTest<ObjectiveCubit, ObjectiveState>(
    'falls back to an assumed body when nothing has been logged, and says so',
    build: () {
      final getBodyProfileUseCase = MockGetBodyProfileUseCase();
      when(getBodyProfileUseCase.call).thenReturn(const BodyProfile());
      final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
      when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildObjectiveCubit(getBodyProfileUseCase: getBodyProfileUseCase, getLatestBodyWeightUseCase: getLatestBodyWeightUseCase);
    },
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.hasWeighIn, isFalse);
      expect(cubit.state.weightKg, BodyProfile.defaultWeightKg);
      expect(cubit.state.objective, isNull);
    },
  );

  blocPresentationTest<ObjectiveCubit, ObjectiveState, ObjectivePresentationEvent>(
    'the first load shows no overlay, because the page draws its own content',
    build: () {
      final getBodyProfileUseCase = MockGetBodyProfileUseCase();
      when(getBodyProfileUseCase.call).thenReturn(const BodyProfile());
      final getLatestBodyWeightUseCase = MockGetLatestBodyWeightUseCase();
      when(getLatestBodyWeightUseCase.call).thenAnswer((_) async => const Success(null));
      return CubitsFactories.buildObjectiveCubit(getBodyProfileUseCase: getBodyProfileUseCase, getLatestBodyWeightUseCase: getLatestBodyWeightUseCase);
    },
    act: (cubit) => cubit.load(),
    expectPresentation: () => <ObjectivePresentationEvent>[],
  );

  test('saving persists the objective and the goals it derives', () async {
    final saveBodyProfileUseCase = MockSaveBodyProfileUseCase();
    when(() => saveBodyProfileUseCase(any())).thenAnswer((_) async {});
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildObjectiveCubit(saveBodyProfileUseCase: saveBodyProfileUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase)
      ..objectiveChanged(FitnessObjective.gainMuscle)
      ..heightChanged(185);
    await cubit.saveObjective();

    final savedProfile = verify(() => saveBodyProfileUseCase(captureAny())).captured.single as BodyProfile;
    expect(savedProfile, const BodyProfile(heightCm: 185, objective: FitnessObjective.gainMuscle));

    final savedGoals = verify(() => saveMacroGoalsUseCase(captureAny())).captured.single as MacroGoals;
    expect(DietModality.matching(savedGoals), DietModality.highProtein);
  });

  test('switching from a cut to maintenance raises the saved calorie target', () async {
    final saveBodyProfileUseCase = MockSaveBodyProfileUseCase();
    when(() => saveBodyProfileUseCase(any())).thenAnswer((_) async {});
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    final cubit = CubitsFactories.buildObjectiveCubit(saveBodyProfileUseCase: saveBodyProfileUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase)
      ..objectiveChanged(FitnessObjective.loseWeight);
    await cubit.saveObjective();
    cubit.objectiveChanged(FitnessObjective.maintainWeight);
    await cubit.saveObjective();

    final savedGoals = verify(() => saveMacroGoalsUseCase(captureAny())).captured.cast<MacroGoals>();
    expect(savedGoals.last.calorieGoal, greaterThan(savedGoals.first.calorieGoal));
  });

  test('nothing is written until an objective is picked', () async {
    final saveBodyProfileUseCase = MockSaveBodyProfileUseCase();
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    final cubit = CubitsFactories.buildObjectiveCubit(saveBodyProfileUseCase: saveBodyProfileUseCase, saveMacroGoalsUseCase: saveMacroGoalsUseCase);

    expect(cubit.state.canSave, isFalse);
    await cubit.saveObjective();

    verifyNever(() => saveBodyProfileUseCase(any()));
    verifyNever(() => saveMacroGoalsUseCase(any()));
  });
}
