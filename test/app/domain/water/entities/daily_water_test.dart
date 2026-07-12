import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

import '../../../../factories/entities/water_log_factory.dart';

void main() {
  test('sums amounts across all entries', () {
    final dailyWater = DailyWater(entries: [WaterLogFactory.build(), WaterLogFactory.build(amountMl: 500)]);

    expect(dailyWater.totalMl, 750);
  });

  test('total is zero with no entries', () {
    const dailyWater = DailyWater(entries: []);

    expect(dailyWater.totalMl, 0);
  });
}
