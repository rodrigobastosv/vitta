import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';

/// How a quantity was typed. Grams are what the domain stores either way, so
/// this only decides which number the user reads and writes - and which one is
/// recorded alongside the grams so the day view can say it back.
///
/// A unit and a millilitre are deliberately not a third and fourth
/// [UnitSystem]: metric/imperial is a g/oz and mL/fl oz choice, while two eggs
/// are two eggs in either. So [units] bypasses the unit system entirely, and
/// [volume] converts through it only because a fluid ounce genuinely is a
/// different reading of the same volume.
enum FoodQuantityMode {
  weight,
  units,
  volume;

  /// The measure a food is read in when it is not being counted: a liquid in
  /// millilitres (nobody weighs milk), everything else by weight.
  static FoodQuantityMode measureFor(Food food) => food.isMeasuredByVolume ? .volume : .weight;

  /// Total, so no call site needs a `!` on [Food.gramsPerUnit] or
  /// [Food.densityGPerMl]: a mode the food can't be measured in resolves to no
  /// quantity at all rather than a wrong one.
  LoggedQuantity? quantityFor({required double value, required Food food, required UnitSystem unitSystem}) => switch (this) {
    .weight => LoggedQuantity.weight(unitSystem.displayWeightToGrams(value)),
    .units => switch (food.gramsPerUnit) {
      final gramsPerUnit? => LoggedQuantity.units(units: value, grams: value * gramsPerUnit),
      null => null,
    },
    .volume => switch (food.densityGPerMl) {
      final density? => _volumeQuantity(value: value, density: density, unitSystem: unitSystem),
      null => null,
    },
  };

  /// The inverse: the number this mode's field shows for a quantity in grams, so
  /// editing either field can keep the other in step.
  double? displayValueFor({required double grams, required Food food, required UnitSystem unitSystem}) => switch (this) {
    .weight => unitSystem.gramsToDisplayWeight(grams),
    .units => switch (food.gramsPerUnit) {
      final gramsPerUnit? => grams / gramsPerUnit,
      null => null,
    },
    .volume => switch (food.densityGPerMl) {
      final density? => unitSystem.millilitersToDisplayVolume(grams / density),
      null => null,
    },
  };

  LoggedQuantity _volumeQuantity({required double value, required double density, required UnitSystem unitSystem}) {
    final milliliters = unitSystem.displayVolumeToMilliliters(value);
    return LoggedQuantity.volume(milliliters: milliliters, grams: milliliters * density);
  }
}
