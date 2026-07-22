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

extension LoadConversion on UnitSystem {
  static const _kilogramsPerPound = 0.45359237;

  String get loadUnitLabel => switch (this) {
    .metric => 'kg',
    .imperial => 'lb',
  };

  double kilogramsToDisplayLoad(double kilograms) => switch (this) {
    .metric => kilograms,
    .imperial => kilograms / _kilogramsPerPound,
  };

  double displayLoadToKilograms(double value) => switch (this) {
    .metric => value,
    .imperial => value * _kilogramsPerPound,
  };
}

// Body height, kept in centimetres the same way body weight is kept in kilograms.
// Separate from DistanceConversion (km/mi, a cardio distance) for the same reason
// LoadConversion is separate from WeightConversion: they share no unit and are
// never interchangeable.
extension HeightConversion on UnitSystem {
  static const _centimetersPerInch = 2.54;

  String get heightUnitLabel => switch (this) {
    .metric => 'cm',
    .imperial => 'in',
  };

  double centimetersToDisplayHeight(double centimeters) => switch (this) {
    .metric => centimeters,
    .imperial => centimeters / _centimetersPerInch,
  };

  double displayHeightToCentimeters(double value) => switch (this) {
    .metric => value,
    .imperial => value * _centimetersPerInch,
  };
}

extension DistanceConversion on UnitSystem {
  static const _metersPerMile = 1609.344;
  static const _metersPerKilometer = 1000.0;

  String get distanceUnitLabel => switch (this) {
    .metric => 'km',
    .imperial => 'mi',
  };

  double metersToDisplayDistance(double meters) => switch (this) {
    .metric => meters / _metersPerKilometer,
    .imperial => meters / _metersPerMile,
  };

  double displayDistanceToMeters(double value) => switch (this) {
    .metric => value * _metersPerKilometer,
    .imperial => value * _metersPerMile,
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
