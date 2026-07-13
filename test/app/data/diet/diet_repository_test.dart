import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';

import '../../../factories/entities/food_factory.dart';
import '../../../factories/entities/food_log_entry_factory.dart';
import '../../../factories/entities/food_log_factory.dart';
import '../../../factories/repositories_factories.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
  test('getMonthlyMacros groups the monthly log entries by their logged date', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final from = DateTime(2026, 7);
    final to = DateTime(2026, 7, 31);
    final entries = [
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'a', loggedDate: DateTime(2026, 7, 5))),
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'b', loggedDate: DateTime(2026, 7, 5))),
      FoodLogEntryFactory.build(log: FoodLogFactory.build(id: 'c', loggedDate: DateTime(2026, 7, 11))),
    ];
    when(() => supabaseDietDataSource.getMonthlyLog(from: from, to: to)).thenAnswer((_) async => Success(entries));
    final repository = RepositoriesFactories.buildDietRepository(supabaseDietDataSource: supabaseDietDataSource);

    final macrosResult = await repository.getMonthlyMacros(from: from, to: to);

    macrosResult.when(
      (error) => fail('expected Success, got Failure($error)'),
      (macrosByDate) {
        expect(macrosByDate.keys.toSet(), {DateTime(2026, 7, 5), DateTime(2026, 7, 11)});
        expect(macrosByDate[DateTime(2026, 7, 5)]!.entries, hasLength(2));
        expect(macrosByDate[DateTime(2026, 7, 11)]!.entries, hasLength(1));
      },
    );
  });

  test('searchFoods returns catalog matches without querying Open Food Facts', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final catalogFoods = [FoodFactory.build()];
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
    when(
      () => supabaseDietDataSource.searchCatalog(query: 'banana'),
    ).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    when(() => openFoodFactsDataSource.searchFoods(query: 'banana')).thenAnswer((_) async => Success(offFoods));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'banana');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, offFoods));
  });
}
