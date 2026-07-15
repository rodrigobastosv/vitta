import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/workout/entities/routine_draft.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_cubit.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/routine_form/routine_form_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/exercise_factory.dart';
import '../../../../factories/entities/routine_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const RoutineDraft());
    registerFallbackValue(<String, Object?>{});
  });

  blocTest<RoutineFormCubit, RoutineFormState>(
    'reorder moves an exercise to the index the list reports, without re-adjusting it',
    build: CubitsFactories.buildRoutineFormCubit,
    act: (cubit) {
      cubit
        ..addExercise(ExerciseFactory.build(id: 'a'))
        ..addExercise(ExerciseFactory.build(id: 'b'))
        ..addExercise(ExerciseFactory.build(id: 'c'))
        // Dragging the first item to the end: onReorderItem reports the index
        // after removal, so 2 means "last", not "second".
        ..reorderExercise(oldIndex: 0, newIndex: 2);
    },
    skip: 3,
    expect: () => [
      isA<RoutineFormState>().having((state) => [for (final exercise in state.draft.exercises) exercise.id], 'exercise order', [
        'b',
        'c',
        'a',
      ]),
    ],
  );

  blocPresentationTest<RoutineFormCubit, RoutineFormState, RoutineFormPresentationEvent>(
    'refuses to save a routine with a name but no exercises',
    build: CubitsFactories.buildRoutineFormCubit,
    act: (cubit) async {
      cubit.nameChanged('Treino A');
      await cubit.save();
    },
    expectPresentation: () => [isA<RoutineFormIncomplete>()],
  );

  blocPresentationTest<RoutineFormCubit, RoutineFormState, RoutineFormPresentationEvent>(
    'refuses to save exercises with no name',
    build: CubitsFactories.buildRoutineFormCubit,
    act: (cubit) async {
      cubit.addExercise(ExerciseFactory.build());
      await cubit.save();
    },
    expectPresentation: () => [isA<RoutineFormIncomplete>()],
  );

  test('editing saves against the existing routine rather than creating a second one', () async {
    useMockLog();
    final saveRoutineUseCase = MockSaveRoutineUseCase();
    final routine = RoutineFactory.build(id: 'routine-7', exercises: [ExerciseFactory.build()]);
    when(
      () => saveRoutineUseCase(
        draft: any(named: 'draft'),
        routine: any(named: 'routine'),
      ),
    ).thenAnswer((_) async => Success(routine));
    final cubit = CubitsFactories.buildRoutineFormCubit(saveRoutineUseCase: saveRoutineUseCase, routine: routine);

    await cubit.save();

    verify(
      () => saveRoutineUseCase(
        draft: any(named: 'draft'),
        routine: routine,
      ),
    ).called(1);
  });

  test('a new routine seeds an empty draft; editing seeds from the routine', () {
    final routine = RoutineFactory.build(name: 'Treino B', exercises: [ExerciseFactory.build()]);

    expect(CubitsFactories.buildRoutineFormCubit().state.draft.name, '');
    expect(CubitsFactories.buildRoutineFormCubit(routine: routine).state.draft.name, 'Treino B');
    expect(CubitsFactories.buildRoutineFormCubit(routine: routine).state.isEditing, isTrue);
  });
}
