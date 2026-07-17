class FoodQuantitySelection {
  const FoodQuantitySelection({this.quantityGrams, this.quantityUnits});

  final double? quantityGrams;
  final double? quantityUnits;

  bool get isValid => quantityGrams != null && quantityGrams! > 0;
}
