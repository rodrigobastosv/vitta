import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

class Food extends Equatable {
  const Food({
    required this.name,
    required this.source,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.micronutrientsPer100g = const {},
    this.id,
    this.brand,
    this.barcode,
    this.imageUrl,
  });

  factory Food.fromMap(Map<String, dynamic> row) => Food(
    id: row['id'] as String,
    name: row['name'] as String,
    brand: row['brand'] as String?,
    barcode: row['barcode'] as String?,
    source: FoodSource.fromWireValue(row['source'] as String),
    caloriesPer100g: (row['calories_per_100g'] as num).toDouble(),
    proteinPer100g: (row['protein_per_100g'] as num).toDouble(),
    carbsPer100g: (row['carbs_per_100g'] as num).toDouble(),
    fatPer100g: (row['fat_per_100g'] as num).toDouble(),
    fiberPer100g: (row['fiber_per_100g'] as num?)?.toDouble() ?? 0,
    micronutrientsPer100g: _micronutrientsFromMap(row['micronutrients']),
    imageUrl: row['image_url'] as String?,
  );

  static Map<Nutrient, double> _micronutrientsFromMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const {};
    }
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (Nutrient.fromWireKey(key) case final nutrient? when value is num) nutrient: value.toDouble(),
    };
  }

  /// Null until the food has been persisted (e.g. a fresh Open Food Facts search
  /// result or a custom food the user hasn't saved yet).
  final String? id;
  final String name;
  final String? brand;
  final String? barcode;
  final FoodSource source;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final Map<Nutrient, double> micronutrientsPer100g;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    barcode,
    source,
    caloriesPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    fiberPer100g,
    micronutrientsPer100g,
    imageUrl,
  ];
}
