import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/http/vt_http_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_plausibility.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

class OpenFoodFactsDataSource {
  OpenFoodFactsDataSource({required this._httpClient});

  final VTHttpClient _httpClient;

  // Open Food Facts is worldwide and the search was unfiltered, so a Portuguese
  // query came back full of products nobody here can buy - a Lithuanian milk
  // drink and Czech baby purée outranked "Banana" (issue #285). The market tag
  // is what makes the live fallback usable; a second market would make this a
  // setting rather than a constant, but the app ships in one.
  static const _market = 'brazil';

  Future<Result<VTError, List<Food>>> searchFoods({required String query}) async {
    final responseResult = await _httpClient.get(
      VTHttpRequest(
        path: '/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'search_simple': '1',
          'action': 'process',
          'json': '1',
          'page_size': '20',
          'tagtype_0': 'countries',
          'tag_contains_0': 'contains',
          'tag_0': _market,
          // OFF's own scan counter. Without it the API returns matches in no
          // useful order, which is the same "relevance is never considered"
          // failure the catalog query had.
          'sort_by': 'unique_scans_n',
          'fields': 'code,product_name,brands,nutriments',
        },
      ),
    );

    return responseResult.when(Failure.new, (value) => Success(_parseProducts(value)));
  }

  List<Food> _parseProducts(Map<String, dynamic> body) {
    final products = (body['products'] as List<dynamic>?) ?? [];
    return products.map(_parseProduct).nonNulls.toList();
  }

  Food? _parseProduct(dynamic rawProduct) {
    final product = rawProduct as Map<String, dynamic>;
    final name = product['product_name'] as String?;
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    if (name == null || name.isEmpty || nutriments == null) {
      return null;
    }

    final calories = _numOrNull(nutriments['energy-kcal_100g']);
    final protein = _numOrNull(nutriments['proteins_100g']);
    final carbs = _numOrNull(nutriments['carbohydrates_100g']);
    final fat = _numOrNull(nutriments['fat_100g']);
    if (calories == null || protein == null || carbs == null || fat == null) {
      return null;
    }
    // Dropped rather than shown: a search result is one tap from being saved
    // into the shared catalog, so an impossible row here becomes everyone's
    // impossible row. Only physically impossible figures are dropped - a food
    // stating no nutrition at all is left alone, because salt, water and black
    // coffee are exactly that and are real things to log.
    if (!FoodPlausibility.isPlausible(caloriesPer100g: calories)) {
      return null;
    }

    return Food(
      name: name,
      brand: product['brands'] as String?,
      barcode: product['code'] as String?,
      source: .openFoodFacts,
      caloriesPer100g: calories,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
      fiberPer100g: _numOrNull(nutriments['fiber_100g']) ?? 0,
      micronutrientsPer100g: _micronutrients(nutriments),
    );
  }

  Map<Nutrient, double> _micronutrients(Map<String, dynamic> nutriments) => {
    for (final nutrient in Nutrient.values) nutrient: ?_numOrNull(nutriments[nutrient.offKey]),
  };

  double? _numOrNull(dynamic value) => switch (value) {
    final num n => n.toDouble(),
    _ => null,
  };
}
