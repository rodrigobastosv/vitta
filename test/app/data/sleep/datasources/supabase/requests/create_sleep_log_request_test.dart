import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/sleep/datasources/supabase/requests/create_sleep_log_request.dart';
import 'package:vitta/app/domain/sleep/entities/sleep_log_source.dart';

void main() {
  test('a manual log defaults to source manual with no external id', () {
    final json = CreateSleepLogRequest(
      userId: 'user-1',
      bedTime: DateTime.utc(2026, 7, 10, 22, 30),
      wakeTime: DateTime.utc(2026, 7, 11, 6, 45),
      qualityRating: 4,
    ).toJson();

    expect(json['source'], 'manual');
    expect(json['external_id'], isNull);
    expect(json['quality_rating'], 4);
    expect(json['logged_date'], '2026-07-11');
  });

  test('an imported log carries source health and the external id', () {
    final json = CreateSleepLogRequest(
      userId: 'user-1',
      bedTime: DateTime.utc(2026, 7, 10, 23),
      wakeTime: DateTime.utc(2026, 7, 11, 6, 30),
      source: SleepLogSource.health,
      externalId: 'ext-1',
    ).toJson();

    expect(json['source'], 'health');
    expect(json['external_id'], 'ext-1');
    expect(json['quality_rating'], isNull);
  });
}
