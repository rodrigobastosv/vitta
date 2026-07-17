import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

enum FoodQuantityMode {
  weight,
  units;

  double? gramsFor({required double value, required Food food, required UnitSystem unitSystem}) => switch (this) {
    .weight => unitSystem.displayWeightToGrams(value),
    .units => switch (food.gramsPerUnit) {
      final gramsPerUnit? => value * gramsPerUnit,
      null => null,
    },
  };

  double? unitsFor(double value) => switch (this) {
    .weight => null,
    .units => value,
  };
}
