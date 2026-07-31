import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

import '../../../factories/entities/food_factory.dart';
import '../../../factories/entities/food_log_entry_factory.dart';
import '../../../factories/entities/food_log_factory.dart';
import '../../../factories/repositories_factories.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
  test('getMacrosInRange groups the monthly log entries by their logged date', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final from = DateTime(2026, 7);
    final to = DateTime(2026, 7, 31);
    final entries = [
      FoodLogEntryFactory.build(
        log: FoodLogFactory.build(id: 'a', loggedDate: DateTime(2026, 7, 5)),
      ),
      FoodLogEntryFactory.build(
        log: FoodLogFactory.build(id: 'b', loggedDate: DateTime(2026, 7, 5)),
      ),
      FoodLogEntryFactory.build(
        log: FoodLogFactory.build(id: 'c', loggedDate: DateTime(2026, 7, 11)),
      ),
    ];
    when(() => supabaseDietDataSource.getLogsInRange(from: from, to: to)).thenAnswer((_) async => Success(entries));
    final repository = RepositoriesFactories.buildDietRepository(supabaseDietDataSource: supabaseDietDataSource);

    final macrosResult = await repository.getMacrosInRange(from: from, to: to);

    macrosResult.when((error) => fail('expected Success, got Failure($error)'), (macrosByDate) {
      expect(macrosByDate.keys.toSet(), {DateTime(2026, 7, 5), DateTime(2026, 7, 11)});
      expect(macrosByDate[DateTime(2026, 7, 5)]!.entries, hasLength(2));
      expect(macrosByDate[DateTime(2026, 7, 11)]!.entries, hasLength(1));
    });
  });

  test('searchFoods returns catalog matches alone when the catalog is not sparse', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final catalogFoods = List.generate(5, (index) => FoodFactory.build(id: 'food-$index', name: 'Banana $index'));
    when(() => supabaseDietDataSource.searchCatalog(query: 'banana')).thenAnswer((_) async => Success(catalogFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'banana');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, catalogFoods));
    verifyNever(() => openFoodFactsDataSource.searchFoods(query: any(named: 'query')));
  });

  test('searchFoods falls back to Open Food Facts when the catalog has no matches', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final offFoods = [FoodFactory.build()];
    when(() => supabaseDietDataSource.searchCatalog(query: 'banana')).thenAnswer((_) async => const Success([]));
    when(() => openFoodFactsDataSource.searchFoods(query: 'banana')).thenAnswer((_) async => Success(offFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'banana');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, offFoods));
  });

  test('searchFoods falls back to Open Food Facts when the catalog search fails', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final offFoods = [FoodFactory.build()];
    when(() => supabaseDietDataSource.searchCatalog(query: 'banana')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    when(() => openFoodFactsDataSource.searchFoods(query: 'banana')).thenAnswer((_) async => Success(offFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'banana');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, offFoods));
  });

  test('searchFoods does not pad a thin catalog answer with Open Food Facts', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final catalogFoods = [FoodFactory.build(id: 'catalog', name: 'Carne Moída Patinho')];
    when(() => supabaseDietDataSource.searchCatalog(query: 'patinho')).thenAnswer((_) async => Success(catalogFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'patinho');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, catalogFoods));
    verifyNever(() => openFoodFactsDataSource.searchFoods(query: any(named: 'query')));
  });

  test('searchFoods falls back to Open Food Facts only when the catalog answers nothing', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final offFoods = [FoodFactory.build(id: null, name: 'Patinho Bovino', barcode: 'other')];
    when(() => supabaseDietDataSource.searchCatalog(query: 'patinho')).thenAnswer((_) async => const Success([]));
    when(() => openFoodFactsDataSource.searchFoods(query: 'patinho')).thenAnswer((_) async => Success(offFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'patinho');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, offFoods));
  });

  test('getRecentMeals groups a range of entries into one meal per day and meal type', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final entries = [
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'a', loggedDate: DateTime(2026, 7, 29))),
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'b', loggedDate: DateTime(2026, 7, 29))),
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'c', loggedDate: DateTime(2026, 7, 29), mealType: MealType.dinner)),
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'd', loggedDate: DateTime(2026, 7, 28))),
    ];
    when(() => supabaseDietDataSource.getLogsInRange(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(entries));
    final repository = RepositoriesFactories.buildDietRepository(supabaseDietDataSource: supabaseDietDataSource);

    final mealsResult = await withClock(Clock.fixed(DateTime(2026, 7, 29, 20, 17)), () => repository.getRecentMeals(limit: 8));

    mealsResult.when((error) => fail('expected Success, got Failure($error)'), (meals) {
      expect(meals, hasLength(3));
      expect(meals.map((meal) => (meal.date, meal.mealType)), [
        (DateTime(2026, 7, 29), MealType.dinner),
        (DateTime(2026, 7, 29), MealType.breakfast),
        (DateTime(2026, 7, 28), MealType.breakfast),
      ]);
      expect(meals.first.entries, hasLength(1));
      expect(meals[1].entries, hasLength(2));
    });
  });

  // The window is read by date rather than by row count precisely so a meal
  // cannot come back with some of its foods missing, so the range asked for has
  // to cover whole days and end on today.
  test('getRecentMeals reads whole days up to today', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    when(() => supabaseDietDataSource.getLogsInRange(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => const Success([]));
    final repository = RepositoriesFactories.buildDietRepository(supabaseDietDataSource: supabaseDietDataSource);

    await withClock(Clock.fixed(DateTime(2026, 7, 29, 20, 17)), () => repository.getRecentMeals(limit: 8));

    verify(() => supabaseDietDataSource.getLogsInRange(from: DateTime(2026, 7, 15), to: DateTime(2026, 7, 29))).called(1);
  });

  test('getRecentMeals keeps only the most recent meals up to the limit', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final entries = [
      for (var day = 1; day <= 6; day++) FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'log-$day', loggedDate: DateTime(2026, 7, 20 + day))),
    ];
    when(() => supabaseDietDataSource.getLogsInRange(from: any(named: 'from'), to: any(named: 'to'))).thenAnswer((_) async => Success(entries));
    final repository = RepositoriesFactories.buildDietRepository(supabaseDietDataSource: supabaseDietDataSource);

    final mealsResult = await withClock(Clock.fixed(DateTime(2026, 7, 29)), () => repository.getRecentMeals(limit: 2));

    mealsResult.when((error) => fail('expected Success, got Failure($error)'), (meals) {
      expect(meals.map((meal) => meal.date), [DateTime(2026, 7, 26), DateTime(2026, 7, 25)]);
    });
  });
}
