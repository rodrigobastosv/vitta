import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/water/entities/daily_water.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the daily water for the given date', () async {
    final waterRepository = MockWaterRepository();
    final useCase = UseCasesFactories.buildGetDailyWaterUseCase(waterRepository: waterRepository);
    final date = DateTime(2026, 7, 11);
    const dailyWater = DailyWater(entries: []);
    when(() => waterRepository.getDailyWater(date: date)).thenAnswer((_) async => const Success(dailyWater));

    final dailyWaterResult = await useCase(date: date);

    dailyWaterResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, dailyWater));
  });
}
