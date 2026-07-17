import 'package:health/health.dart';
import 'package:vitta/app/core/services/health/health_sleep_session.dart';

/// Thin adapter over the `health` package (Health Connect on Android, HealthKit on
/// iOS) so nothing above `core/services/` imports `package:health` directly — the
/// same boundary `ImagePickerService`/`SupabaseService` establish for their vendors.
class HealthService {
  HealthService({Health? health}) : _health = health ?? Health();

  final Health _health;

  static const List<HealthDataType> _sleepTypes = [HealthDataType.SLEEP_SESSION];
  static const List<HealthDataAccess> _readAccess = [HealthDataAccess.READ];

  Future<bool> isAvailable() async {
    await _health.configure();
    return _health.isHealthConnectAvailable();
  }

  Future<bool> requestSleepAuthorization() async {
    await _health.configure();
    return _health.requestAuthorization(_sleepTypes, permissions: _readAccess);
  }

  Future<List<HealthSleepSession>> readSleepSessions({required DateTime from, required DateTime to}) async {
    await _health.configure();
    final points = await _health.getHealthDataFromTypes(types: _sleepTypes, startTime: from, endTime: to);
    return [
      for (final point in points)
        if (point.dateTo.isAfter(point.dateFrom))
          HealthSleepSession(start: point.dateFrom, end: point.dateTo, externalId: point.uuid),
    ];
  }

  /// Debug-only helper to seed a sleep session so the import flow can be exercised
  /// on an emulator/device without a real watch. Not called in release builds.
  Future<void> writeSampleSleep({required DateTime start, required DateTime end}) async {
    await _health.configure();
    await _health.writeHealthData(
      value: end.difference(start).inMinutes.toDouble(),
      type: HealthDataType.SLEEP_SESSION,
      startTime: start,
      endTime: end,
    );
  }
}
