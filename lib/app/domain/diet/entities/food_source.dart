enum FoodSource {
  custom,
  openFoodFacts;

  static FoodSource fromWireValue(String value) => switch (value) {
    'custom' => FoodSource.custom,
    'open_food_facts' => FoodSource.openFoodFacts,
    _ => throw ArgumentError('Unknown food source: $value'),
  };

  String get wireValue => switch (this) {
    FoodSource.custom => 'custom',
    FoodSource.openFoodFacts => 'open_food_facts',
  };
}
