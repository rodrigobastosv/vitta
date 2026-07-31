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

  // Deliberately the ONLY rule, and the reason is a mistake this nearly made.
  //
  // The first cut also called a row of nothing but zeros implausible, on the
  // grounds that it states no nutrition. Running the audit against the real
  // catalog before deleting anything showed what is actually in that bucket:
  // "Salt", "Aquafina", "Apă minerală plată", "Gold Espresso Intense Coffee" -
  // water, salt and black coffee genuinely ARE zero-calorie, zero-macro foods,
  // and 1,089 rows would have been deleted to remove some unknown number of
  // blank records.
  //
  // Over 900 kcal is *provably* impossible; all-zero is *indistinguishable* from
  // a real food, and nothing in the row separates the two. So this rejects only
  // what physics rejects. statesNoNutrition below is the softer question, and it
  // is for reporting to a human - never for dropping or deleting.
  static bool isPlausible({required double caloriesPer100g}) => caloriesPer100g <= maxCaloriesPer100g;

  // Carries no nutrition at all. Suspicious in bulk - most such rows are Open
  // Food Facts entries whose contributor never filled the panel in - but it is a
  // question, not a verdict: see above.
  static bool statesNoNutrition({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
  }) => caloriesPer100g == 0 && proteinPer100g == 0 && carbsPer100g == 0 && fatPer100g == 0;
}
