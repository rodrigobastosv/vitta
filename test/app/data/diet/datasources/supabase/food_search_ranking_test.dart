import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/diet/datasources/supabase/food_search_ranking.dart';

Map<String, dynamic> row(String id, {String source = 'open_food_facts'}) => {'id': id, 'source': source};

void main() {
  group('termFor', () {
    test('folds accents, so typing without them still reaches the food', () {
      expect(FoodSearchRanking.termFor('feijão'), 'feijao');
      expect(FoodSearchRanking.termFor('feijao'), 'feijao');
      expect(FoodSearchRanking.termFor('Requeijão'), 'requeijao');
      expect(FoodSearchRanking.termFor('linguiça'), 'linguica');
    });

    test('strips LIKE wildcards, so a typed % searches instead of matching everything', () {
      expect(FoodSearchRanking.termFor('%'), '');
      expect(FoodSearchRanking.termFor('ban%ana'), 'banana');
      expect(FoodSearchRanking.termFor('_'), '');
    });

    test('trims, so a trailing space from a keyboard does not become a word-boundary miss', () {
      expect(FoodSearchRanking.termFor('  arroz  '), 'arroz');
    });
  });

  group('rank', () {
    test('keeps a row at its best tier, so an exact match is not repeated lower down', () {
      final exact = row('banana');
      final ranked = FoodSearchRanking.rank([
        [exact],
        [row('banana-bread'), exact],
        [row('aussie-bar-banana-walnut'), exact],
      ], limit: 20);

      expect(ranked.map((r) => r['id']), ['banana', 'banana-bread', 'aussie-bar-banana-walnut']);
    });

    test('an exact match outranks an alphabetically earlier substring match', () {
      final ranked = FoodSearchRanking.rank([
        [row('banana')],
        <Map<String, dynamic>>[],
        <Map<String, dynamic>>[],
        [row('apple-banana-puree'), row('aussie-bar-banana-walnut'), row('banana')],
        <Map<String, dynamic>>[],
      ], limit: 20);

      expect(ranked.first['id'], 'banana');
    });

    test('curated foods lead their own tier without jumping a better tier', () {
      final ranked = FoodSearchRanking.rank([
        [row('exact-off')],
        [row('prefix-off'), row('prefix-generic', source: 'generic')],
      ], limit: 20);

      expect(ranked.map((r) => r['id']), ['exact-off', 'prefix-generic', 'prefix-off']);
    });

    test('the order the query returned survives inside a tier', () {
      final ranked = FoodSearchRanking.rank([
        [row('most-logged'), row('less-logged'), row('never-logged')],
      ], limit: 20);

      expect(ranked.map((r) => r['id']), ['most-logged', 'less-logged', 'never-logged']);
    });

    test('honours the limit', () {
      final ranked = FoodSearchRanking.rank([
        [for (var index = 0; index < 30; index++) row('food-$index')],
      ], limit: 20);

      expect(ranked, hasLength(20));
    });

    test('no tier matched is an empty result rather than an error', () {
      expect(FoodSearchRanking.rank([<Map<String, dynamic>>[], <Map<String, dynamic>>[]], limit: 20), isEmpty);
    });
  });
}
