import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_cubit.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_extra.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_page.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/add_food_list_section.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_meal_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/food_factory.dart';
import '../../../../factories/entities/food_log_entry_factory.dart';
import '../../../../fixtures/premium_fixture.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpRecentTab(
  WidgetTester tester, {
  List<FoodLogEntry> recentFoods = const [],
  List<RecentMeal> recentMeals = const [],
  MockCopyFoodLogsUseCase? copyFoodLogsUseCase,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final getRecentlyLoggedFoodsUseCase = MockGetRecentlyLoggedFoodsUseCase();
  when(() => getRecentlyLoggedFoodsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Success(recentFoods));
  final getRecentMealsUseCase = MockGetRecentMealsUseCase();
  when(() => getRecentMealsUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Success(recentMeals));
  final getFavoriteFoodsUseCase = MockGetFavoriteFoodsUseCase();
  when(getFavoriteFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
  final getRecentSearchesUseCase = MockGetRecentSearchesUseCase();
  when(getRecentSearchesUseCase.call).thenReturn(const []);
  final getMyFoodsUseCase = MockGetMyFoodsUseCase();
  when(getMyFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));
  final getMyRecipeFoodsUseCase = MockGetMyRecipeFoodsUseCase();
  when(getMyRecipeFoodsUseCase.call).thenAnswer((_) async => const Success(<Food>[]));

  if (G.isRegistered<AddFoodCubit>()) {
    G.unregister<AddFoodCubit>();
  }
  G.registerFactory<AddFoodCubit>(
    () => CubitsFactories.buildAddFoodCubit(
      getRecentlyLoggedFoodsUseCase: getRecentlyLoggedFoodsUseCase,
      getRecentMealsUseCase: getRecentMealsUseCase,
      getFavoriteFoodsUseCase: getFavoriteFoodsUseCase,
      getRecentSearchesUseCase: getRecentSearchesUseCase,
      getMyFoodsUseCase: getMyFoodsUseCase,
      getMyRecipeFoodsUseCase: getMyRecipeFoodsUseCase,
      copyFoodLogsUseCase: copyFoodLogsUseCase ?? MockCopyFoodLogsUseCase(),
    ),
  );
  addTearDown(() => G.unregister<AddFoodCubit>());

  await tester.pumpWidget(
    MaterialApp(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: withTestPremium(AddFoodPage(extra: AddFoodExtra(loggedDate: DateTime(2026, 7, 26)))),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Recent'));
  await tester.pumpAndSettle();
}

void main() {
  RecentMeal buildMeal() => RecentMeal(
    date: DateTime(2026, 7, 26),
    mealType: .breakfast,
    entries: [FoodLogEntryFactory.build(food: FoodFactory.build(id: 'egg', name: 'Ovo'))],
  );

  testWidgets('foods and meals are each named, so the meals are not buried under the foods', (tester) async {
    await pumpRecentTab(
      tester,
      recentFoods: [FoodLogEntryFactory.build(food: FoodFactory.build(id: 'rice', name: 'Arroz'))],
      recentMeals: [buildMeal()],
    );

    expect(find.text('Recently entered'), findsOneWidget);
    expect(find.text('Recent meals'), findsOneWidget);
    expect(find.text('Arroz'), findsOneWidget);
  });

  testWidgets('a meal row says how many foods one tap adds, so it does not read as a list of foods', (tester) async {
    await pumpRecentTab(
      tester,
      recentMeals: [
        RecentMeal(
          date: DateTime(2026, 7, 25),
          mealType: .breakfast,
          entries: [
            FoodLogEntryFactory.build(food: FoodFactory.build(id: 'egg', name: 'Ovo')),
            FoodLogEntryFactory.build(food: FoodFactory.build(id: 'coffee', name: 'Cafe')),
            FoodLogEntryFactory.build(food: FoodFactory.build(id: 'couscous', name: 'Cuscuz')),
          ],
        ),
      ],
    );

    expect(find.textContaining('3 foods'), findsOneWidget);
  });

  testWidgets('one tap on a meal logs every food it holds, against the day being added to', (tester) async {
    final copyFoodLogsUseCase = MockCopyFoodLogsUseCase();
    when(() => copyFoodLogsUseCase(entries: any(named: 'entries'), targetDate: any(named: 'targetDate'))).thenAnswer((_) async => const Success(null));
    final meal = buildMeal();
    await pumpRecentTab(tester, recentMeals: [meal], copyFoodLogsUseCase: copyFoodLogsUseCase);

    await tester.tap(find.byType(RecentMealTile));
    await tester.pumpAndSettle();

    verify(() => copyFoodLogsUseCase(entries: meal.entries, targetDate: DateTime(2026, 7, 26))).called(1);
  });

  testWidgets('a long run of recent foods is capped, so the meals section is reachable without expanding it', (tester) async {
    await pumpRecentTab(
      tester,
      recentFoods: [
        for (var index = 0; index < AddFoodListSection.defaultCollapsedCount + 4; index++)
          FoodLogEntryFactory.build(food: FoodFactory.build(id: 'food-$index', name: 'Alimento $index')),
      ],
      recentMeals: [buildMeal()],
    );

    expect(find.text('Alimento ${AddFoodListSection.defaultCollapsedCount - 1}'), findsOneWidget);
    expect(find.text('Alimento ${AddFoodListSection.defaultCollapsedCount}'), findsNothing);
    expect(find.text('Recent meals'), findsOneWidget);
  });
}
