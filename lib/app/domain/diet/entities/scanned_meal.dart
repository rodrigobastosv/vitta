import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class ScannedMeal extends Equatable {
  const ScannedMeal({required this.items});

  factory ScannedMeal.fromMap(Map<String, dynamic> row) => ScannedMeal(
    items: [
      for (final item in (row['items'] as List? ?? const []))
        if (item is Map<String, dynamic>) ScannedMealItem.fromMap(item),
    ],
  );

  final List<ScannedMealItem> items;

  bool get hasItems => items.isNotEmpty;

  @override
  List<Object?> get props => [items];
}

class ScannedMealItem extends Equatable {
  const ScannedMealItem({
    required this.name,
    required this.estimatedGrams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
  });

  factory ScannedMealItem.fromMap(Map<String, dynamic> row) => ScannedMealItem(
    name: row['name'] as String,
    estimatedGrams: (row['estimatedGrams'] as num?)?.toDouble() ?? 0,
    caloriesPer100g: (row['caloriesPer100g'] as num?)?.toDouble() ?? 0,
    proteinPer100g: (row['proteinPer100g'] as num?)?.toDouble() ?? 0,
    carbsPer100g: (row['carbsPer100g'] as num?)?.toDouble() ?? 0,
    fatPer100g: (row['fatPer100g'] as num?)?.toDouble() ?? 0,
    fiberPer100g: (row['fiberPer100g'] as num?)?.toDouble() ?? 0,
  );

  final String name;
  final double estimatedGrams;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;

  Food toFood() => Food(
    name: name,
    source: .custom,
    caloriesPer100g: caloriesPer100g,
    proteinPer100g: proteinPer100g,
    carbsPer100g: carbsPer100g,
    fatPer100g: fatPer100g,
    fiberPer100g: fiberPer100g,
  );

  @override
  List<Object?> get props => [name, estimatedGrams, caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g, fiberPer100g];
}

class ScannedMealLogItem extends Equatable {
  const ScannedMealLogItem({required this.item, required this.quantityGrams});

  final ScannedMealItem item;
  final double quantityGrams;

  @override
  List<Object?> get props => [item, quantityGrams];
}
