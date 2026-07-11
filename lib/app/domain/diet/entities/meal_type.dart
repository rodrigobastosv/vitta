enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  static MealType fromWireValue(String value) => MealType.values.firstWhere((mealType) => mealType.wireValue == value);

  String get wireValue => name;
}
