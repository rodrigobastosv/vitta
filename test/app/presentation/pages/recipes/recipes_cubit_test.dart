import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_cubit.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipes/recipes_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../factories/entities/recipe_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  blocTest<RecipesCubit, RecipesState>(
    'emits the loaded recipes',
    build: () {
      final getRecipesUseCase = MockGetRecipesUseCase();
      when(getRecipesUseCase.call).thenAnswer((_) async => Success([RecipeFactory.build()]));
      return CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase);
    },
    act: (cubit) => cubit.loadRecipes(),
    expect: () => [isA<RecipesState>().having((state) => state.recipes, 'recipes', hasLength(1))],
  );

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'shows then hides the overlay on a reload (the first load shows the skeleton)',
    build: () {
      final getRecipesUseCase = MockGetRecipesUseCase();
      when(getRecipesUseCase.call).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase);
    },
    seed: RecipesState.new,
    act: (cubit) => cubit.loadRecipes(),
    expectPresentation: () => [isA<RecipesShowLoading>(), isA<RecipesHideLoading>()],
  );

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'the first load shows no overlay - the skeleton covers it',
    build: () {
      final getRecipesUseCase = MockGetRecipesUseCase();
      when(getRecipesUseCase.call).thenAnswer((_) async => const Success([]));
      return CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase);
    },
    act: (cubit) => cubit.loadRecipes(),
    expectPresentation: () => <RecipesPresentationEvent>[],
  );

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'emits RecipesError when loading fails',
    build: () {
      final getRecipesUseCase = MockGetRecipesUseCase();
      when(getRecipesUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase);
    },
    act: (cubit) => cubit.loadRecipes(),
    expectPresentation: () => [isA<RecipesError>().having((event) => event.message, 'message', 'boom')],
  );

  test('deleting a recipe reloads the list', () async {
    final getRecipesUseCase = MockGetRecipesUseCase();
    final deleteRecipeUseCase = MockDeleteRecipeUseCase();
    when(getRecipesUseCase.call).thenAnswer((_) async => const Success([]));
    when(() => deleteRecipeUseCase(recipeId: 'recipe-1')).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase, deleteRecipeUseCase: deleteRecipeUseCase);

    await cubit.deleteRecipe(recipeId: 'recipe-1');

    verify(getRecipesUseCase.call).called(1);
  });

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'a failed delete reports the error without reloading',
    build: () {
      final getRecipesUseCase = MockGetRecipesUseCase();
      final deleteRecipeUseCase = MockDeleteRecipeUseCase();
      when(() => deleteRecipeUseCase(recipeId: 'recipe-1')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildRecipesCubit(getRecipesUseCase: getRecipesUseCase, deleteRecipeUseCase: deleteRecipeUseCase);
    },
    act: (cubit) => cubit.deleteRecipe(recipeId: 'recipe-1'),
    expectPresentation: () => [isA<RecipesError>()],
  );

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'logging a recipe logs its food to the given day and announces it',
    build: () {
      final recipe = RecipeFactory.build();
      final logFoodUseCase = MockLogFoodUseCase();
      when(
        () => logFoodUseCase(food: recipe.food, loggedDate: DateTime(2026, 7, 22), mealType: .dinner, quantityGrams: 450),
      ).thenAnswer((_) async => Success(FoodLogFactory.build()));
      return CubitsFactories.buildRecipesCubit(logFoodUseCase: logFoodUseCase);
    },
    act: (cubit) => cubit.logRecipe(recipeFood: RecipeFactory.build().food, loggedDate: DateTime(2026, 7, 22, 15, 30), mealType: .dinner, quantityGrams: 450),
    expectPresentation: () => [isA<RecipeLogged>().having((event) => event.mealType, 'mealType', MealType.dinner)],
  );

  blocPresentationTest<RecipesCubit, RecipesState, RecipesPresentationEvent>(
    'a failed recipe log announces nothing',
    build: () {
      final recipe = RecipeFactory.build();
      final logFoodUseCase = MockLogFoodUseCase();
      when(
        () => logFoodUseCase(food: recipe.food, loggedDate: DateTime(2026, 7, 22), mealType: .dinner, quantityGrams: 450),
      ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
      return CubitsFactories.buildRecipesCubit(logFoodUseCase: logFoodUseCase);
    },
    act: (cubit) => cubit.logRecipe(recipeFood: RecipeFactory.build().food, loggedDate: DateTime(2026, 7, 22), mealType: .dinner, quantityGrams: 450),
    expectPresentation: () => <RecipesPresentationEvent>[],
  );
}
