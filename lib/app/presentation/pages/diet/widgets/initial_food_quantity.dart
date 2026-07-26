import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';

/// What a fresh log sheet opens at, so every sheet that logs a food agrees.
///
/// A countable food leads with one item (see issue #143) - logging "an egg" is
/// one tap, and the weight is only there to read back. A liquid opens at one
/// glass, the same 200 mL the water quick-add presets lead with, because 100 mL
/// is not an amount anyone drinks. Everything else opens at the 100 g the
/// per-100g macros are stated for.
const double defaultLiquidMilliliters = 200;
const double defaultQuantityGrams = 100;

LoggedQuantity initialFoodQuantityFor(Food food) => switch (food) {
  Food(gramsPerUnit: final gramsPerUnit?) => LoggedQuantity.units(units: 1, grams: gramsPerUnit),
  Food(densityGPerMl: final density?) => LoggedQuantity.volume(
    milliliters: defaultLiquidMilliliters,
    grams: defaultLiquidMilliliters * density,
  ),
  _ => const LoggedQuantity.weight(defaultQuantityGrams),
};
