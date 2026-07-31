// Whether a set of per-100g figures can describe a real food (issue #285).
//
// Measured on the live catalog before this existed: 1,090 Open Food Facts rows
// carried nothing but zeros, and 187 claimed more than 900 kcal per 100 g. Both
// are contributed data nobody checked, and both reach the user as a row that
// looks loggable and silently reports the wrong day - which is the same reason
// the scan prompts return null rather than guess.
//
// Shared by OpenFoodFactsDataSource (so junk is never imported in the first
// place) and tool/audit_food_catalog.dart (so the junk already imported can be
// found and removed). One definition, because a rule the importer and the
// auditor disagreed on would let a row be rejected on the way in and kept on the
// way out.
abstract class FoodPlausibility {
  // Pure fat is 9 kcal/g, so 900 kcal per 100 g is the physical ceiling for any
  // food. Anything above it is a unit mix-up (kJ reported as kcal) or a typo.
  static const maxCaloriesPer100g = 900.0;

  static bool isPlausible({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
  }) {
    if (caloriesPer100g > maxCaloriesPer100g) {
      return false;
    }
    // A row of nothing but zeros states no nutrition at all. It is not a
    // zero-calorie food - water and black coffee still carry a real name and
    // real (zero) macros deliberately entered; this is an empty record.
    return caloriesPer100g > 0 || proteinPer100g > 0 || carbsPer100g > 0 || fatPer100g > 0;
  }
}
