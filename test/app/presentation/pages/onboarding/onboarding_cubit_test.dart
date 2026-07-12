import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_cubit.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  final completeOnboardingUseCase = MockCompleteOnboardingUseCase();
  blocTest<OnboardingCubit, OnboardingState>(
    'delegates to the use case when completing onboarding',
    build: () {
      when(completeOnboardingUseCase.call).thenAnswer((_) async {});
      return CubitsFactories.buildOnboardingCubit(completeOnboardingUseCase: completeOnboardingUseCase);
    },
    act: (cubit) => cubit.completeOnboarding(),
    expect: () => <OnboardingState>[],
    verify: (_) => verify(completeOnboardingUseCase.call).called(1),
  );
}
