enum NutrientUnit {
  milligram('mg', 1000),
  microgram('µg', 1000000);

  const NutrientUnit(this.symbol, this.perGram);

  final String symbol;
  final double perGram;

  double fromGrams(double grams) => grams * perGram;
}

enum Nutrient {
  vitaminA('vitamin_a', 'vitamin-a_100g', NutrientUnit.microgram),
  vitaminC('vitamin_c', 'vitamin-c_100g', NutrientUnit.milligram),
  vitaminD('vitamin_d', 'vitamin-d_100g', NutrientUnit.microgram),
  vitaminE('vitamin_e', 'vitamin-e_100g', NutrientUnit.milligram),
  vitaminK('vitamin_k', 'vitamin-k_100g', NutrientUnit.microgram),
  vitaminB1('vitamin_b1', 'vitamin-b1_100g', NutrientUnit.milligram),
  vitaminB2('vitamin_b2', 'vitamin-b2_100g', NutrientUnit.milligram),
  vitaminB3('vitamin_b3', 'vitamin-pp_100g', NutrientUnit.milligram),
  vitaminB6('vitamin_b6', 'vitamin-b6_100g', NutrientUnit.milligram),
  folate('folate', 'folates_100g', NutrientUnit.microgram),
  vitaminB12('vitamin_b12', 'vitamin-b12_100g', NutrientUnit.microgram),
  calcium('calcium', 'calcium_100g', NutrientUnit.milligram),
  iron('iron', 'iron_100g', NutrientUnit.milligram),
  magnesium('magnesium', 'magnesium_100g', NutrientUnit.milligram),
  potassium('potassium', 'potassium_100g', NutrientUnit.milligram),
  sodium('sodium', 'sodium_100g', NutrientUnit.milligram),
  zinc('zinc', 'zinc_100g', NutrientUnit.milligram);

  const Nutrient(this.wireKey, this.offKey, this.unit);

  final String wireKey;
  final String offKey;
  final NutrientUnit unit;

  static Nutrient? fromWireKey(String wireKey) {
    for (final nutrient in Nutrient.values) {
      if (nutrient.wireKey == wireKey) {
        return nutrient;
      }
    }
    return null;
  }
}
