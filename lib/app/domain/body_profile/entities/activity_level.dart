enum ActivityLevel {
  sedentary(multiplier: 1.2),
  lightlyActive(multiplier: 1.375),
  moderatelyActive(multiplier: 1.55),
  veryActive(multiplier: 1.725),
  extraActive(multiplier: 1.9);

  const ActivityLevel({required this.multiplier});

  static ActivityLevel? fromWireValue(String? value) {
    for (final level in values) {
      if (level.wireValue == value) {
        return level;
      }
    }
    return null;
  }

  final double multiplier;

  String get wireValue => name;
}
