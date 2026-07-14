import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/recipe_factory.dart';
import '../../../../factories/entities/recipe_ingredient_factory.dart';
import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FoodFactory.build());
  });

  test('saves an ingredient that is not in the catalog yet before linking it', () async {
    final dietRepository = MockDietRepository();
    final unsavedFood = FoodFactory.build(id: null, name: 'Oatmeal');
    when(() => dietRepository.saveFood(food: unsavedFood)).thenAnswer((_) async => Success(FoodFactory.build(id: 'food-9')));
    when(
      () => dietRepository.saveFood(food: any(named: 'food', that: isA<Food>().having((food) => food.source, 'source', FoodSource.recipe))),
    ).thenAnswer((_) async => Success(FoodFactory.build(id: 'recipe-food-1')));
    when(
      () => dietRepository.createRecipe(foodId: any(named: 'foodId'), ingredients: any(named: 'ingredients')),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));

    await UseCasesFactories.buildCreateRecipeUseCase(dietRepository: dietRepository)(
      draft: RecipeDraft(name: 'Porridge', ingredients: [RecipeIngredient(food: unsavedFood, quantityGrams: 80)]),
    );

    final capturedIngredients =
        verify(() => dietRepository.createRecipe(foodId: 'recipe-food-1', ingredients: captureAny(named: 'ingredients'))).captured.single
            as List<RecipeIngredient>;
    expect(capturedIngredients.single.food.id, 'food-9');
    expect(capturedIngredients.single.quantityGrams, 80);
  });

  test('leaves an ingredient that already has an id alone', () async {
    final dietRepository = MockDietRepository();
    when(
      () => dietRepository.saveFood(food: any(named: 'food')),
    ).thenAnswer((_) async => Success(FoodFactory.build(id: 'recipe-food-1')));
    when(
      () => dietRepository.createRecipe(foodId: any(named: 'foodId'), ingredients: any(named: 'ingredients')),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));

    await UseCasesFactories.buildCreateRecipeUseCase(dietRepository: dietRepository)(
      draft: RecipeDraft(name: 'Porridge', ingredients: [RecipeIngredientFactory.build()]),
    );

    verify(() => dietRepository.saveFood(food: any(named: 'food'))).called(1);
  });

  test('saves the recipe itself as a food carrying the rolled-up macros', () async {
    final dietRepository = MockDietRepository();
    when(
      () => dietRepository.saveFood(food: any(named: 'food')),
    ).thenAnswer((_) async => Success(FoodFactory.build(id: 'recipe-food-1')));
    when(
      () => dietRepository.createRecipe(foodId: any(named: 'foodId'), ingredients: any(named: 'ingredients')),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));

    await UseCasesFactories.buildCreateRecipeUseCase(dietRepository: dietRepository)(
      draft: RecipeDraft(
        name: 'Porridge',
        ingredients: [
          RecipeIngredientFactory.build(food: FoodFactory.build(caloriesPer100g: 100), quantityGrams: 200),
        ],
      ),
    );

    final capturedFood = verify(() => dietRepository.saveFood(food: captureAny(named: 'food'))).captured.single as Food;
    expect(capturedFood.name, 'Porridge');
    expect(capturedFood.source, FoodSource.recipe);
    expect(capturedFood.caloriesPer100g, 100);
  });

  test('gives up without creating a recipe when an ingredient fails to save', () async {
    final dietRepository = MockDietRepository();
    when(() => dietRepository.saveFood(food: any(named: 'food'))).thenAnswer((_) async => const Failure(VTError(message: 'boom')));

    final createdResult = await UseCasesFactories.buildCreateRecipeUseCase(dietRepository: dietRepository)(
      draft: RecipeDraft(
        name: 'Porridge',
        ingredients: [RecipeIngredientFactory.build(food: FoodFactory.build(id: null))],
      ),
    );

    expect(createdResult.when((error) => error.message, (_) => null), 'boom');
    verifyNever(() => dietRepository.createRecipe(foodId: any(named: 'foodId'), ingredients: any(named: 'ingredients')));
  });
}
