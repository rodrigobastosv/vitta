import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/water/entities/water_log.dart';

void main() {
  test('fromMap parses a Supabase water_logs row', () {
    final waterLog = WaterLog.fromMap(const {'id': 'water-1', 'logged_date': '2026-07-11', 'amount_ml': 250});

    expect(waterLog, WaterLog(id: 'water-1', loggedDate: DateTime(2026, 7, 11), amountMl: 250));
  });
}
