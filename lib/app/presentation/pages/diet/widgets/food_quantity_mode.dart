import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

/// How the user is typing a quantity: a weight, or a count of whole items.
///
/// [units] is deliberately not a third [UnitSystem]: metric/imperial is a g/oz
/// choice, while two eggs are two eggs in either system. Counting therefore
/// bypasses [WeightConversion] rather than extending it.
enum FoodQuantityMode {
  weight,
  units;

  /// Null when the typed value can't be resolved to grams - counting a food
  /// with no known unit weight. Total by construction, so no call site needs a
  /// `!` on [Food.gramsPerUnit].
  double? gramsFor({required double value, required Food food, required UnitSystem unitSystem}) => switch (this) {
    .weight => unitSystem.displayWeightToGrams(value),
    .units => switch (food.gramsPerUnit) {
      final gramsPerUnit? => value * gramsPerUnit,
      null => null,
    },
  };

  /// The same portion read in [target]'s terms, so flipping the switch keeps
  /// the number meaning the food it meant rather than being reread as the other
  /// unit. Null when either side can't be resolved, which leaves the field
  /// alone rather than filling it with a wrong number.
  double? valueIn(FoodQuantityMode target, {required double value, required Food food, required UnitSystem unitSystem}) {
    final grams = gramsFor(value: value, food: food, unitSystem: unitSystem);
    if (grams == null) {
      return null;
    }
    return switch (target) {
      .weight => unitSystem.gramsToDisplayWeight(grams),
      .units => switch (food.gramsPerUnit) {
        final gramsPerUnit? => grams / gramsPerUnit,
        null => null,
      },
    };
  }

  /// What gets recorded on the log alongside the grams - null whenever the user
  /// weighed rather than counted.
  double? unitsFor(double value) => switch (this) {
    .weight => null,
    .units => value,
  };
}
