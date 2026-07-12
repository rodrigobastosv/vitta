import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../factories/use_cases_factories.dart';
import '../../../../mocks/repositories_mocks.dart';

void main() {
  test('delegates completion to the repository', () async {
    final onboardingRepository = MockOnboardingRepository();
    final useCase = UseCasesFactories.buildCompleteOnboardingUseCase(onboardingRepository: onboardingRepository);
    when(onboardingRepository.completeOnboarding).thenAnswer((_) async {});

    await useCase();

    verify(onboardingRepository.completeOnboarding).called(1);
  });
}
