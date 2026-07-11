import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

class Food extends Equatable {
  const Food({
    required this.name,
    required this.source,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.id,
    this.brand,
    this.barcode,
  });

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

  @override
  List<Object?> get props => [id, name, brand, barcode, source, caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g];
}
