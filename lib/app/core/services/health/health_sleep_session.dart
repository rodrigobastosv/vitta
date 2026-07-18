class HealthSleepSession {
  const HealthSleepSession({required this.start, required this.end, required this.externalId});

  final DateTime start;
  final DateTime end;

  /// The health record's own id, used to dedupe re-imports of the same night.
  final String externalId;
}
