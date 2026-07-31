import 'package:vitta/app/core/text/accent_folding.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

// How well a row matched, best first. The order of the cases IS the ranking -
// FoodSearchRanking.rank keeps a row at the best tier it appeared in, which is
// what stops "Aussie Bar Banana Walnut" outranking "Banana". `brand` is last
// because matching a manufacturer is a weaker signal about the food than
// matching the food's own name.
enum FoodSearchTier { equals, startsWith, word, contains, brand }

// The relevance half of catalog search (issue #285), kept apart from
// SupabaseDietDataSource so it can be tested: a datasource is exercised against
// a mocked SupabaseService, so PostgREST's fluent builder is never run and any
// ordering logic left inside it would be untestable by construction - the same
// reason order_direction_test.dart has to be a source scan.
abstract class FoodSearchRanking {
  // What the tiers actually match on. Folded so "feijao" reaches "feijão", and
  // stripped of LIKE's own wildcards so a typed "%" searches for the character
  // rather than matching the entire catalog.
  static String termFor(String query) => AccentFolding.fold(query.trim()).replaceAll(RegExp('[%_]'), '');

  // Rows in `tiers` are already ordered within themselves by the query (#56
  // popularity, then name). This concatenates them best-tier-first and drops a
  // row it has already seen, so a row matching `equals` is not repeated when the
  // looser `contains` tier matches it too.
  static List<Map<String, dynamic>> rank(List<List<Map<String, dynamic>>> tiers, {required int limit}) {
    final rowsById = <String, Map<String, dynamic>>{};
    for (final rows in tiers) {
      for (final row in _curatedFirst(rows)) {
        rowsById.putIfAbsent(row['id'] as String, () => row);
      }
    }
    return rowsById.values.take(limit).toList();
  }

  // Curated whole foods (source 'generic', issue #180) lead their tier: Open
  // Food Facts is a barcode database of packaged products, so a plain "banana"
  // is either absent from it or buried under brands. A stable partition of rows
  // the query already ordered, not a re-sort, so the popularity order survives
  // inside each half.
  static Iterable<Map<String, dynamic>> _curatedFirst(List<Map<String, dynamic>> rows) {
    bool isCurated(Map<String, dynamic> row) => row['source'] == FoodSource.generic.wireValue;
    return [...rows.where(isCurated), ...rows.where((row) => !isCurated(row))];
  }
}
