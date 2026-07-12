enum UnitSystem {
  metric,
  imperial;

  static UnitSystem fromWireValue(String value) => UnitSystem.values.firstWhere((system) => system.wireValue == value);

  String get wireValue => name;
}

extension WeightConversion on UnitSystem {
  static const _gramsPerOunce = 28.3495;

  String get weightUnitLabel => switch (this) {
    UnitSystem.metric => 'g',
    UnitSystem.imperial => 'oz',
  };

  double gramsToDisplayWeight(double grams) => switch (this) {
    UnitSystem.metric => grams,
    UnitSystem.imperial => grams / _gramsPerOunce,
  };

  double displayWeightToGrams(double value) => switch (this) {
    UnitSystem.metric => value,
    UnitSystem.imperial => value * _gramsPerOunce,
  };
}

extension VolumeConversion on UnitSystem {
  static const _mlPerFluidOunce = 29.5735;

  String get volumeUnitLabel => switch (this) {
    UnitSystem.metric => 'mL',
    UnitSystem.imperial => 'fl oz',
  };

  double millilitersToDisplayVolume(double milliliters) => switch (this) {
    UnitSystem.metric => milliliters,
    UnitSystem.imperial => milliliters / _mlPerFluidOunce,
  };

  double displayVolumeToMilliliters(double value) => switch (this) {
    UnitSystem.metric => value,
    UnitSystem.imperial => value * _mlPerFluidOunce,
  };
}
