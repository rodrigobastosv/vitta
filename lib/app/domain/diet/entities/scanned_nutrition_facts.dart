import 'package:equatable/equatable.dart';

class ScannedNutritionFacts extends Equatable {
  const ScannedNutritionFacts({this.caloriesPer100g, this.proteinPer100g, this.carbsPer100g, this.fatPer100g, this.fiberPer100g});

  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fiberPer100g;

  bool get hasAnyValue =>
      caloriesPer100g != null || proteinPer100g != null || carbsPer100g != null || fatPer100g != null || fiberPer100g != null;

  @override
  List<Object?> get props => [caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g, fiberPer100g];
}
