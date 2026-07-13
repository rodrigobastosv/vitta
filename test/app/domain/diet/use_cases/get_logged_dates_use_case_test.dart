import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the logged dates for the given range', () async {
    final dietRepository = MockDietRepository();
    final useCase = UseCasesFactories.buildGetLoggedDatesUseCase(dietRepository: dietRepository);
    final from = DateTime(2026, 7);
    final to = DateTime(2026, 7, 31);
    final loggedDates = {DateTime(2026, 7, 5), DateTime(2026, 7, 11)};
    when(() => dietRepository.getLoggedDates(from: from, to: to)).thenAnswer((_) async => Success(loggedDates));

    final loggedDatesResult = await useCase(from: from, to: to);

    loggedDatesResult.when((error) => fail('expected Success, got Failure($error)'), (value) => expect(value, loggedDates));
  });
}
