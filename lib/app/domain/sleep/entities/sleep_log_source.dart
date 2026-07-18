enum SleepLogSource {
  manual('manual'),
  health('health');

  const SleepLogSource(this.wireValue);

  final String wireValue;

  static SleepLogSource fromWire(String? wireValue) =>
      SleepLogSource.values.firstWhere((source) => source.wireValue == wireValue, orElse: () => SleepLogSource.manual);
}
