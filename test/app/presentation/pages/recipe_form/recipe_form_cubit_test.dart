import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/recipe_factory.dart';
import '../../../../factories/entities/recipe_ingredient_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const RecipeDraft());
  });

  blocTest<RecipeFormCubit, RecipeFormState>(
    'adds and removes ingredients, keeping the running totals in the draft',
    build: CubitsFactories.buildRecipeFormCubit,
    act: (cubit) {
      cubit
        ..addIngredient(RecipeIngredientFactory.build(quantityGrams: 200))
        ..addIngredient(RecipeIngredientFactory.build())
        ..removeIngredientAt(0);
    },
    expect: () => [
      isA<RecipeFormState>().having((state) => state.draft.totalGrams, 'totalGrams', 200),
      isA<RecipeFormState>().having((state) => state.draft.totalGrams, 'totalGrams', 300),
      isA<RecipeFormState>().having((state) => state.draft.totalGrams, 'totalGrams', 100),
    ],
  );

  blocPresentationTest<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
    'refuses to save a recipe with a name but no ingredients',
    build: CubitsFactories.buildRecipeFormCubit,
    act: (cubit) {
      cubit.nameChanged('Lasagna');
      return cubit.submit();
    },
    expectPresentation: () => [isA<RecipeFormIncomplete>()],
  );

  blocPresentationTest<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
    'refuses to save ingredients with no name',
    build: CubitsFactories.buildRecipeFormCubit,
    act: (cubit) {
      cubit.addIngredient(RecipeIngredientFactory.build());
      return cubit.submit();
    },
    expectPresentation: () => [isA<RecipeFormIncomplete>()],
  );

  blocPresentationTest<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
    'emits RecipeCreated once the recipe is saved',
    build: () {
      final createRecipeUseCase = MockCreateRecipeUseCase();
      when(() => createRecipeUseCase(draft: any(named: 'draft'))).thenAnswer((_) async => Success(RecipeFactory.build()));
      return CubitsFactories.buildRecipeFormCubit(createRecipeUseCase: createRecipeUseCase);
    },
    act: (cubit) {
      cubit
        ..nameChanged('Lasagna')
        ..addIngredient(RecipeIngredientFactory.build());
      return cubit.submit();
    },
    expectPresentation: () => [isA<RecipeFormShowLoading>(), isA<RecipeFormHideLoading>(), isA<RecipeCreated>()],
  );

  blocPresentationTest<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
    'emits RecipeFormError when saving fails',
    build: () {
      final createRecipeUseCase = MockCreateRecipeUseCase();
      when(() => createRecipeUseCase(draft: any(named: 'draft'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildRecipeFormCubit(createRecipeUseCase: createRecipeUseCase);
    },
    act: (cubit) {
      cubit
        ..nameChanged('Lasagna')
        ..addIngredient(RecipeIngredientFactory.build());
      return cubit.submit();
    },
    expectPresentation: () => [
      isA<RecipeFormShowLoading>(),
      isA<RecipeFormHideLoading>(),
      isA<RecipeFormError>().having((event) => event.message, 'message', 'boom'),
    ],
  );

  test('logs a recipe_created action with how many ingredients went in', () async {
    final loggingService = useMockLog();
    final createRecipeUseCase = MockCreateRecipeUseCase();
    when(() => createRecipeUseCase(draft: any(named: 'draft'))).thenAnswer((_) async => Success(RecipeFactory.build()));
    final cubit = CubitsFactories.buildRecipeFormCubit(createRecipeUseCase: createRecipeUseCase);
    cubit
      ..nameChanged('Lasagna')
      ..addIngredient(RecipeIngredientFactory.build())
      ..addIngredient(RecipeIngredientFactory.build());

    await cubit.submit();

    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, ['recipe_created', {'ingredients': 2}]);
  });
}
