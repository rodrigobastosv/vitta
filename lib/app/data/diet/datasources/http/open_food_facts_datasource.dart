import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/http/vt_http_request.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

class OpenFoodFactsDataSource {
  OpenFoodFactsDataSource({required this._httpClient});

  final VTHttpClient _httpClient;

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

    return Food(
      name: name,
      brand: product['brands'] as String?,
      barcode: product['code'] as String?,
      source: FoodSource.openFoodFacts,
      caloriesPer100g: calories,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
      fiberPer100g: _numOrNull(nutriments['fiber_100g']) ?? 0,
    );
  }

  double? _numOrNull(dynamic value) => switch (value) {
    final num n => n.toDouble(),
    _ => null,
  };
}
