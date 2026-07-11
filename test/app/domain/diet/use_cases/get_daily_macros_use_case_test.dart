import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';

import '../../../../mocks/repositories_mocks.dart';

void main() {
  late MockDietRepository dietRepository;
  late GetDailyMacrosUseCase useCase;

  setUp(() {
    dietRepository = MockDietRepository();
    useCase = GetDailyMacrosUseCase(dietRepository: dietRepository);
  });

  test('returns the daily macros for the given date', () async {
    final date = DateTime(2026, 7, 11);
    const dailyMacros = DailyMacros(entries: []);
    when(() => dietRepository.getDailyMacros(date: date)).thenAnswer((_) async => const Success(dailyMacros));

    final result = await useCase(date: date);

    switch (result) {
      case Failure(:final error):
        fail('expected Success, got Failure($error)');
      case Success(:final value):
        expect(value, dailyMacros);
    }
  });
}
