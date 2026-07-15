import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

abstract class FoodFactory {
  static Food build({
    String? id = 'food-1',
    String name = 'Banana',
    String? brand,
    String? barcode,
    FoodSource source = FoodSource.custom,
    double caloriesPer100g = 89,
    double proteinPer100g = 1.1,
    double carbsPer100g = 22.8,
    double fatPer100g = 0.3,
    double fiberPer100g = 2.6,
    Map<Nutrient, double> micronutrientsPer100g = const {},
    String? imageUrl,
    double? gramsPerUnit,
  }) => Food(
    id: id,
    name: name,
    brand: brand,
    barcode: barcode,
    source: source,
    caloriesPer100g: caloriesPer100g,
    proteinPer100g: proteinPer100g,
    carbsPer100g: carbsPer100g,
    fatPer100g: fatPer100g,
    fiberPer100g: fiberPer100g,
    micronutrientsPer100g: micronutrientsPer100g,
    imageUrl: imageUrl,
    gramsPerUnit: gramsPerUnit,
  );
}
