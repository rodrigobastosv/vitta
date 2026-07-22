enum FoodSource {
  custom,
  openFoodFacts,
  generic,
  recipe;

  static FoodSource fromWireValue(String value) => switch (value) {
    'custom' => .custom,
    'open_food_facts' => .openFoodFacts,
    'generic' => .generic,
    'recipe' => .recipe,
    _ => throw ArgumentError('Unknown food source: $value'),
  };

  String get wireValue => switch (this) {
    .custom => 'custom',
    .openFoodFacts => 'open_food_facts',
    .generic => 'generic',
    .recipe => 'recipe',
  };
}
