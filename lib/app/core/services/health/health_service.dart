import 'dart:io';

import 'package:health/health.dart';
import 'package:vitta/app/core/services/health/health_sleep_session.dart';

/// Thin adapter over the `health` package (Health Connect on Android, HealthKit on
/// iOS) so nothing above `core/services/` imports `package:health` directly — the
/// same boundary `ImagePickerService`/`SupabaseService` establish for their vendors.
class HealthService {
  HealthService({Health? health}) : _health = health ?? Health();

  final Health _health;

  // Sleep is modelled differently per platform: Health Connect exposes a whole
  // SLEEP_SESSION per night, while HealthKit only has interval samples
  // (asleep/in-bed/stages) — asking iOS for SLEEP_SESSION crashes the native side.
  static const List<HealthDataType> _androidSleepTypes = [HealthDataType.SLEEP_SESSION];
  static const List<HealthDataType> _iosSleepTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  // iOS samples that are part of the same night are bridged into one session when
  // the gap between them is at most this (covers brief awakenings between stages).
  static const Duration _iosSessionGap = Duration(minutes: 60);

  List<HealthDataType> get _sleepTypes => Platform.isAndroid ? _androidSleepTypes : _iosSleepTypes;

  Future<bool> isAvailable() async {
    await _health.configure();
    return _health.isHealthConnectAvailable();
  }

  Future<bool> requestSleepAuthorization() async {
    await _health.configure();
    return _health.requestAuthorization(_sleepTypes, permissions: List<HealthDataAccess>.filled(_sleepTypes.length, HealthDataAccess.READ));
  }

  Future<List<HealthSleepSession>> readSleepSessions({required DateTime from, required DateTime to}) async {
    await _health.configure();
    final points = await _health.getHealthDataFromTypes(types: _sleepTypes, startTime: from, endTime: to);
    final intervals = [
      for (final point in points)
        if (point.dateTo.isAfter(point.dateFrom)) point,
    ];
    if (Platform.isAndroid) {
      return [for (final point in intervals) HealthSleepSession(start: point.dateFrom, end: point.dateTo, externalId: point.uuid)];
    }
    return _mergeIntoSessions(intervals);
  }

  // HealthKit returns a night as many overlapping/adjacent interval samples; fold
  // them into one bed→wake session. The external id is derived from the merged
  // window so a re-sync of the same night dedupes stably.
  List<HealthSleepSession> _mergeIntoSessions(List<HealthDataPoint> points) {
    final sorted = [...points]..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    final sessions = <HealthSleepSession>[];
    DateTime? start;
    DateTime? end;
    for (final point in sorted) {
      if (start == null || end == null) {
        start = point.dateFrom;
        end = point.dateTo;
        continue;
      }
      if (point.dateFrom.difference(end) <= _iosSessionGap) {
        if (point.dateTo.isAfter(end)) {
          end = point.dateTo;
        }
      } else {
        sessions.add(_session(start, end));
        start = point.dateFrom;
        end = point.dateTo;
      }
    }
    if (start != null && end != null) {
      sessions.add(_session(start, end));
    }
    return sessions;
  }

  HealthSleepSession _session(DateTime start, DateTime end) =>
      HealthSleepSession(start: start, end: end, externalId: 'ios-${start.toUtc().toIso8601String()}-${end.toUtc().toIso8601String()}');

  /// Debug-only helper to seed a sleep session so the import flow can be exercised
  /// on an emulator/device without a real watch. Not called in release builds.
  Future<void> writeSampleSleep({required DateTime start, required DateTime end}) async {
    await _health.configure();
    await _health.writeHealthData(
      value: end.difference(start).inMinutes.toDouble(),
      type: Platform.isAndroid ? HealthDataType.SLEEP_SESSION : HealthDataType.SLEEP_ASLEEP,
      startTime: start,
      endTime: end,
    );
  }
}
