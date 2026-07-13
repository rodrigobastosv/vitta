import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('returns the flag from the repository', () {
    final onboardingRepository = MockOnboardingRepository();
    final useCase = UseCasesFactories.buildHasSeenOnboardingUseCase(onboardingRepository: onboardingRepository);
    when(onboardingRepository.hasSeenOnboarding).thenReturn(true);

    expect(useCase(), isTrue);
  });
}
