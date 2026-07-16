import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/recipe_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpRecipeForm(
  WidgetTester tester, {
  required MockSaveRecipeUseCase saveRecipeUseCase,
  RecipeIngredient? pickedIngredient,
  Recipe? recipe,
}) async {
  final getAppSettingsUseCase = MockGetAppSettingsUseCase();
  when(getAppSettingsUseCase.call).thenReturn(const AppSettings());
  if (G.isRegistered<RecipeFormCubit>()) {
    G.unregister<RecipeFormCubit>();
  }
  G.registerFactoryParam<RecipeFormCubit, Recipe?, void>(
    (param, _) => CubitsFactories.buildRecipeFormCubit(
      saveRecipeUseCase: saveRecipeUseCase,
      getAppSettingsUseCase: getAppSettingsUseCase,
      recipe: param,
    ),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(onPressed: () => context.push('/new'), child: const Text('open')),
              ),
            ),
          ),
          GoRoute(
            path: '/new',
            builder: (context, state) => RecipeFormPage(recipe: recipe),
          ),
          GoRoute(
            path: '/ingredient',
            name: 'ingredientPicker',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(onPressed: () => Navigator.of(context).pop(pickedIngredient), child: const Text('pick')),
              ),
            ),
          ),
        ],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> addPickedIngredient(WidgetTester tester) async {
  await tester.tap(find.text('Add ingredient'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('pick'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const RecipeDraft());
    registerFallbackValue(UnitSystem.metric);
  });

  testWidgets('starts with a name field and no totals to show yet', (tester) async {
    await pumpRecipeForm(tester, saveRecipeUseCase: MockSaveRecipeUseCase());

    expect(find.widgetWithText(TextField, 'Recipe name'), findsOneWidget);
    expect(find.text('Add the foods this recipe is made of.'), findsOneWidget);
    expect(find.text('Recipe totals'), findsNothing);
  });

  testWidgets('a picked ingredient shows up and brings the recipe totals with it', (tester) async {
    await pumpRecipeForm(
      tester,
      saveRecipeUseCase: MockSaveRecipeUseCase(),
      pickedIngredient: RecipeIngredient(food: FoodFactory.build(name: 'Oatmeal', caloriesPer100g: 100), quantityGrams: 200),
    );

    await addPickedIngredient(tester);

    expect(find.text('Oatmeal'), findsOneWidget);
    expect(find.text('Recipe totals'), findsOneWidget);
    expect(find.text('200 kcal'), findsOneWidget);
    expect(find.text('200 g total'), findsOneWidget);
  });

  testWidgets('an ingredient can be taken back out', (tester) async {
    await pumpRecipeForm(
      tester,
      saveRecipeUseCase: MockSaveRecipeUseCase(),
      pickedIngredient: RecipeIngredient(food: FoodFactory.build(name: 'Oatmeal'), quantityGrams: 200),
    );
    await addPickedIngredient(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Oatmeal'), findsNothing);
    expect(find.text('Add the foods this recipe is made of.'), findsOneWidget);
  });

  testWidgets('saving without ingredients explains why instead of saving', (tester) async {
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    await pumpRecipeForm(tester, saveRecipeUseCase: saveRecipeUseCase);

    await tester.enterText(find.widgetWithText(TextField, 'Recipe name'), 'Lasagna');
    await tester.tap(find.text('Save recipe'));
    await tester.pumpAndSettle();

    expect(find.text('Give the recipe a name and at least one ingredient.'), findsOneWidget);
    verifyNever(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    );
  });

  testWidgets('saving a complete recipe sends the whole draft and pops back', (tester) async {
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    await pumpRecipeForm(
      tester,
      saveRecipeUseCase: saveRecipeUseCase,
      pickedIngredient: RecipeIngredient(food: FoodFactory.build(name: 'Oatmeal'), quantityGrams: 200),
    );
    await addPickedIngredient(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Recipe name'), 'Porridge');
    await tester.tap(find.text('Save recipe'));
    await tester.pumpAndSettle();

    final capturedDraft =
        verify(
              () => saveRecipeUseCase(
                draft: captureAny(named: 'draft'),
                recipe: any(named: 'recipe'),
              ),
            ).captured.single
            as RecipeDraft;
    expect(capturedDraft.name, 'Porridge');
    expect(capturedDraft.ingredients.single.food.name, 'Oatmeal');
    expect(capturedDraft.totalGrams, 200);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('editing opens already filled in with the recipe', (tester) async {
    await pumpRecipeForm(
      tester,
      saveRecipeUseCase: MockSaveRecipeUseCase(),
      recipe: RecipeFactory.build(
        food: FoodFactory.build(name: 'Lasagna'),
        ingredients: [RecipeIngredient(food: FoodFactory.build(name: 'Pasta'), quantityGrams: 250)],
      ),
    );

    expect(find.text('Edit recipe'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Lasagna'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Recipe totals'), findsOneWidget);
  });

  testWidgets('editing sends the recipe back so it updates rather than duplicates', (tester) async {
    final saveRecipeUseCase = MockSaveRecipeUseCase();
    when(
      () => saveRecipeUseCase(
        draft: any(named: 'draft'),
        recipe: any(named: 'recipe'),
      ),
    ).thenAnswer((_) async => Success(RecipeFactory.build()));
    final recipe = RecipeFactory.build(food: FoodFactory.build(name: 'Lasagna'));
    await pumpRecipeForm(tester, saveRecipeUseCase: saveRecipeUseCase, recipe: recipe);

    await tester.enterText(find.widgetWithText(TextField, 'Lasagna'), 'Lasagna v2');
    await tester.tap(find.text('Save recipe'));
    await tester.pumpAndSettle();

    final capturedDraft =
        verify(
              () => saveRecipeUseCase(
                draft: captureAny(named: 'draft'),
                recipe: recipe,
              ),
            ).captured.single
            as RecipeDraft;
    expect(capturedDraft.name, 'Lasagna v2');
  });

  testWidgets('a recipe with no photo offers to add one', (tester) async {
    await pumpRecipeForm(tester, saveRecipeUseCase: MockSaveRecipeUseCase());

    expect(find.text('Add a photo'), findsOneWidget);
  });
}
