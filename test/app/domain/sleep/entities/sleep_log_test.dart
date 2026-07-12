import 'package:flutter_test/flutter_test.dart';

import '../../../../factories/entities/sleep_log_factory.dart';

void main() {
  test('duration is the difference between wake time and bed time', () {
    final sleepLog = SleepLogFactory.build(bedTime: DateTime(2026, 7, 10, 22, 30), wakeTime: DateTime(2026, 7, 11, 6, 45));

    expect(sleepLog.duration, const Duration(hours: 8, minutes: 15));
  });
}
