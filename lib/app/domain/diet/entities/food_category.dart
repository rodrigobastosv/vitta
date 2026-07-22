// A coarse food group, populated for curated generic foods from USDA's own
// foodCategory (see tool/import_usda_foods.dart and issue #206). Its only job is
// to pick a category icon + tint for a food that has no photo, so search results
// for common whole foods read as a fruit/grain/protein at a glance rather than a
// wall of identical placeholders. Nullable on the food: an unmapped or
// non-generic food simply has none and falls back to the default placeholder.
enum FoodCategory {
  fruit,
  vegetable,
  grain,
  protein,
  dairyEgg,
  legumeNut,
  fatOil,
  beverage,
  sweet,
  condiment;

  // Nullable in and out: the column is nullable, and an unknown wire value is
  // tolerated as "no category" (like Nutrient.fromWireKey) so a value added to
  // the importer before the app models it never throws.
  static FoodCategory? fromWireValue(String? value) => switch (value) {
    'fruit' => .fruit,
    'vegetable' => .vegetable,
    'grain' => .grain,
    'protein' => .protein,
    'dairy_egg' => .dairyEgg,
    'legume_nut' => .legumeNut,
    'fat_oil' => .fatOil,
    'beverage' => .beverage,
    'sweet' => .sweet,
    'condiment' => .condiment,
    _ => null,
  };

  String get wireValue => switch (this) {
    .fruit => 'fruit',
    .vegetable => 'vegetable',
    .grain => 'grain',
    .protein => 'protein',
    .dairyEgg => 'dairy_egg',
    .legumeNut => 'legume_nut',
    .fatOil => 'fat_oil',
    .beverage => 'beverage',
    .sweet => 'sweet',
    .condiment => 'condiment',
  };
}
