import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/text_recognition/ocr_text_line.dart';

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

  test('searchFoods merges Open Food Facts results when the catalog is sparse, deduping by barcode', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final catalogFood = FoodFactory.build(id: 'catalog', name: 'Carne Moída Patinho', barcode: 'shared');
    final duplicateOffFood = FoodFactory.build(id: null, name: 'Patinho', barcode: 'shared');
    final newOffFood = FoodFactory.build(id: null, name: 'Patinho Bovino', barcode: 'other');
    when(() => supabaseDietDataSource.searchCatalog(query: 'patinho')).thenAnswer((_) async => Success([catalogFood]));
    when(() => openFoodFactsDataSource.searchFoods(query: 'patinho')).thenAnswer((_) async => Success([duplicateOffFood, newOffFood]));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'patinho');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, [catalogFood, newOffFood]));
  });

  test('searchFoods keeps the sparse catalog matches when Open Food Facts fails', () async {
    final supabaseDietDataSource = MockSupabaseDietDataSource();
    final openFoodFactsDataSource = MockOpenFoodFactsDataSource();
    final catalogFoods = [FoodFactory.build(id: 'catalog', name: 'Carne Moída Patinho')];
    when(() => supabaseDietDataSource.searchCatalog(query: 'patinho')).thenAnswer((_) async => Success(catalogFoods));
    when(() => openFoodFactsDataSource.searchFoods(query: 'patinho')).thenAnswer((_) async => const Failure(VTError(message: 'boom')));
    final repository = RepositoriesFactories.buildDietRepository(
      supabaseDietDataSource: supabaseDietDataSource,
      openFoodFactsDataSource: openFoodFactsDataSource,
    );

    final foodsResult = await repository.searchFoods(query: 'patinho');

    foodsResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, catalogFoods));
  });

  test('scanNutritionLabel parses the recognized lines into per-100g facts', () async {
    final nutritionOcrDataSource = MockNutritionOcrDataSource();
    const lines = [
      OcrTextLine(text: 'Valor energético 250 kcal', top: 0, bottom: 8, left: 0),
      OcrTextLine(text: 'Proteínas 12 g', top: 10, bottom: 18, left: 0),
      OcrTextLine(text: 'Carboidratos 30 g', top: 20, bottom: 28, left: 0),
      OcrTextLine(text: 'Gorduras totais 8 g', top: 30, bottom: 38, left: 0),
    ];
    when(() => nutritionOcrDataSource.recognizeText(imagePath: '/tmp/label.jpg')).thenAnswer((_) async => const Success(lines));
    final repository = RepositoriesFactories.buildDietRepository(nutritionOcrDataSource: nutritionOcrDataSource);

    final scanResult = await repository.scanNutritionLabel(imagePath: '/tmp/label.jpg');

    scanResult.when((error) => fail('expected Success, got Failure($error)'), (facts) {
      expect(facts.caloriesPer100g, 250);
      expect(facts.proteinPer100g, 12);
      expect(facts.carbsPer100g, 30);
      expect(facts.fatPer100g, 8);
    });
  });

  test('scanNutritionLabel forwards a datasource failure', () async {
    final nutritionOcrDataSource = MockNutritionOcrDataSource();
    when(
      () => nutritionOcrDataSource.recognizeText(imagePath: '/tmp/label.jpg'),
    ).thenAnswer((_) async => const Failure(VTError(message: 'ocr boom')));
    final repository = RepositoriesFactories.buildDietRepository(nutritionOcrDataSource: nutritionOcrDataSource);

    final scanResult = await repository.scanNutritionLabel(imagePath: '/tmp/label.jpg');

    scanResult.when((error) => expect(error.message, 'ocr boom'), (facts) => fail('expected Failure, got Success($facts)'));
  });
}
