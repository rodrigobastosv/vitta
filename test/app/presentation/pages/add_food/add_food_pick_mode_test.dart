import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_page.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../factories/entities/food_log_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  testWidgets('picking a recent food takes the amount you used last time, without a sheet', (tester) async {
    final entry = FoodLogEntryFactory.build(
      food: FoodFactory.build(name: 'Oatmeal'),
      log: FoodLogFactory.build(quantityGrams: 150),
    );
    final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
    when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Success([entry]));
    final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
    when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success([]));
    final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
    when(getRecentSearchesUseCase.call).thenReturn(const []);

    if (G.isRegistered<AddFoodCubit>()) {
      G.unregister<AddFoodCubit>();
    }
    G.registerFactory<AddFoodCubit>(
      () => CubitsFactories.buildAddFoodCubit(
        getRecentlyLoggedFoodsUseCase: getRecentlyLoggedFoodsUseCase,
        getFavoriteFoodsUseCase: getFavoriteFoodsUseCase,
        getRecentSearchesUseCase: getRecentSearchesUseCase,
      ),
    );
    addTearDown(() => G.unregister<AddFoodCubit>());

    RecipeIngredient? picked;
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
                  child: ElevatedButton(
                    onPressed: () async {
                      picked = await context.push<RecipeIngredient>('/pick');
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/pick',
              builder: (context, state) => const AddFoodPage(extra: AddFoodExtra.pickIngredient(unitSystem: .metric)),
            ),
          ],
        ),
        builder: (context, child) => LoaderOverlay(child: child!),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.food.name, 'Oatmeal');
    expect(picked!.quantityGrams, 150, reason: 'the + button accepts the last amount in both modes');
  });
}
