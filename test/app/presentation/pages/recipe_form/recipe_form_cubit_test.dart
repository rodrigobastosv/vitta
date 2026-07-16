import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/recipe_factory.dart';
import '../../../../factories/entities/recipe_ingredient_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const RecipeDraft());
    registerFallbackValue(FoodFactory.build());
  });

  test('editing seeds the draft from the recipe it was handed', () {
    final cubit = CubitsFactories.buildRecipeFormCubit(
      recipe: RecipeFactory.build(
        food: FoodFactory.build(name: 'Lasagna', imageUrl: 'https://example.com/lasagna.jpg'),
        ingredients: [RecipeIngredientFactory.build(quantityGrams: 250)],
      ),
    );

    expect(cubit.isEditing, isTrue);
    expect(cubit.state.draft.name, 'Lasagna');
    expect(cubit.state.draft.imageUrl, 'https://example.com/lasagna.jpg');
    expect(cubit.state.draft.totalGrams, 250);
    expect(cubit.state.draft.isComplete, isTrue);
  });

  test('creating starts from an empty draft', () {
    final cubit = CubitsFactories.buildRecipeFormCubit();

    expect(cubit.isEditing, isFalse);
    expect(cubit.state.draft, const RecipeDraft());
  });

  blocTest<RecipeFormCubit, RecipeFormState>(
    'picking a photo holds the bytes until save',
    build: () {
      final imagePickerService = MockImagePickerService();
      when(
        () => imagePickerService.pickImage(
          source: .gallery,
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: '/tmp/r.png', bytes: Uint8List.fromList([1, 2]), fileExtension: 'png'));
      return CubitsFactories.buildRecipeFormCubit(imagePickerService: imagePickerService);
    },
    act: (cubit) => cubit.pickPhoto(source: .gallery),
    expect: () => [
      isA<RecipeFormState>()
          .having((state) => state.imageBytes, 'imageBytes', Uint8List.fromList([1, 2]))
          .having((state) => state.imageExtension, 'imageExtension', 'png'),
    ],
  );

  test('a picked photo is uploaded and its url rides along on the saved draft', () async {
    final imagePickerService = MockImagePickerService();
    final uploadFoodImageUseCase = MockUploadFoodImageUseCase();
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => imagePickerService.pickImage(
        source: .gallery,
        maxWidth: any(named: 'maxWidth'),
      ),
    ).thenAnswer((_) async => PickedImage(path: '/tmp/r.png', bytes: Uint8List.fromList([1, 2]), fileExtension: 'png'));
    when(
      () => uploadFoodImageUseCase(bytes: Uint8List.fromList([1, 2]), fileExtension: 'png'),
    ).thenAnswer((_) async => const Success('https://example.com/r.png'));
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    final cubit = CubitsFactories.buildRecipeFormCubit(
      imagePickerService: imagePickerService,
      uploadFoodImageUseCase: uploadFoodImageUseCase,
      saveRecipeUseCase: saveRecipeUseCase,
    );
    cubit
      ..nameChanged('Lasagna')
      ..addIngredient(RecipeIngredientFactory.build());

    await cubit.pickPhoto(source: .gallery);
    await cubit.submit();

    final capturedDraft =
        verify(
              () => saveRecipeUseCase(
                draft: captureAny(named: 'draft'),
                recipe: any(named: 'recipe'),
              ),
            ).captured.single
            as RecipeDraft;
    expect(capturedDraft.imageUrl, 'https://example.com/r.png');
  });

  test('saving without touching the photo keeps the url the recipe already had', () async {
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    final recipe = RecipeFactory.build(
      food: FoodFactory.build(name: 'Lasagna', imageUrl: 'https://example.com/old.jpg'),
    );
    final cubit = CubitsFactories.buildRecipeFormCubit(saveRecipeUseCase: saveRecipeUseCase, recipe: recipe);

    await cubit.submit();

    final capturedDraft =
        verify(
              () => saveRecipeUseCase(
                draft: captureAny(named: 'draft'),
                recipe: any(named: 'recipe'),
              ),
            ).captured.single
            as RecipeDraft;
    expect(capturedDraft.imageUrl, 'https://example.com/old.jpg');
  });

  test('an editing save hands the recipe back so the use case updates instead of creating', () async {
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    final recipe = RecipeFactory.build();
    final cubit = CubitsFactories.buildRecipeFormCubit(saveRecipeUseCase: saveRecipeUseCase, recipe: recipe);

    await cubit.submit();

    verify(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: recipe,
      ),
    ).called(1);
  });

  test('a failed photo upload reports the error and never reaches the save', () async {
    final imagePickerService = MockImagePickerService();
    final uploadFoodImageUseCase = MockUploadFoodImageUseCase();
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => imagePickerService.pickImage(
        source: .gallery,
        maxWidth: any(named: 'maxWidth'),
      ),
    ).thenAnswer((_) async => PickedImage(path: '/tmp/r.png', bytes: Uint8List.fromList([1, 2]), fileExtension: 'png'));
    when(
      () => uploadFoodImageUseCase(bytes: Uint8List.fromList([1, 2]), fileExtension: 'png'),
    ).thenAnswer((_) async => const Failure(VTError(message: 'upload failed')));
    final cubit = CubitsFactories.buildRecipeFormCubit(
      imagePickerService: imagePickerService,
      uploadFoodImageUseCase: uploadFoodImageUseCase,
      saveRecipeUseCase: saveRecipeUseCase,
    );
    cubit
      ..nameChanged('Lasagna')
      ..addIngredient(RecipeIngredientFactory.build());
    await cubit.pickPhoto(source: .gallery);

    await cubit.submit();

    verifyNever(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    );
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
    'emits RecipeSaved once the recipe is saved',
    build: () {
      final saveRecipeUseCase = MockSaveRecipeUseCase();
      when(
        () => saveRecipeUseCase(
          draft: any(named: 'draft'),
          recipe: any(named: 'recipe'),
        ),
      ).thenAnswer((_) async => Success(RecipeFactory.build()));
      return CubitsFactories.buildRecipeFormCubit(saveRecipeUseCase: saveRecipeUseCase);
    },
    act: (cubit) {
      cubit
        ..nameChanged('Lasagna')
        ..addIngredient(RecipeIngredientFactory.build());
      return cubit.submit();
    },
    expectPresentation: () => [isA<RecipeFormShowLoading>(), isA<RecipeFormHideLoading>(), isA<RecipeSaved>()],
  );

  blocPresentationTest<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
    'emits RecipeFormError when saving fails',
    build: () {
      final saveRecipeUseCase = MockSaveRecipeUseCase();
      when(
        () => saveRecipeUseCase(
          draft: any(named: 'draft'),
          recipe: any(named: 'recipe'),
        ),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildRecipeFormCubit(saveRecipeUseCase: saveRecipeUseCase);
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
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    final cubit = CubitsFactories.buildRecipeFormCubit(saveRecipeUseCase: saveRecipeUseCase);
    cubit
      ..nameChanged('Lasagna')
      ..addIngredient(RecipeIngredientFactory.build())
      ..addIngredient(RecipeIngredientFactory.build());

    await cubit.submit();

    final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
    expect(captured, [
      'recipe_created',
      {'ingredients': 2},
    ]);
  });
}
