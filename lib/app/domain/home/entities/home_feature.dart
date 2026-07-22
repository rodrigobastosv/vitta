enum HomeFeature {
  diet('diet'),
  water('water'),
  reminders('reminders'),
  workout('workout'),
  sleep('sleep'),
  bodyWeight('body_weight');

  const HomeFeature(this.wireValue);

  final String wireValue;

  static HomeFeature? fromWireValue(String? value) {
    for (final feature in HomeFeature.values) {
      if (feature.wireValue == value) {
        return feature;
      }
    }
    return null;
  }
}
