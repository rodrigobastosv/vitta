// Whether a food's per-100g macros describe it raw or cooked (issue #253).
// 100 g of raw rice is not 100 g of cooked rice - it is roughly three times the
// calories - and USDA FoodData Central ships the two as separate entries, so the
// catalog already holds both and the only thing missing was a way to tell them
// apart. This is a label on the row, deliberately not a conversion: a yield
// factor would have to be recorded per log to keep a later revision from moving
// yesterday's calories, and picking the entry you actually ate is both simpler
// and more honest than converting between two foods.
enum FoodPreparation {
  raw,
  cooked;

  // Nullable in and out, like FoodCategory.fromWireValue: the column is
  // nullable (an apple has no cooking step to state), and an unknown wire value
  // is tolerated as "not stated" so a value an importer writes before the app
  // models it never throws.
  static FoodPreparation? fromWireValue(String? value) => switch (value) {
    'raw' => .raw,
    'cooked' => .cooked,
    _ => null,
  };

  String get wireValue => switch (this) {
    .raw => 'raw',
    .cooked => 'cooked',
  };
}
