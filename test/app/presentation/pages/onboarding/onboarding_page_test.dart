import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/body_profile/use_cases/save_body_profile_use_case.dart';
import 'package:vitta/app/domain/body_weight/use_cases/log_body_weight_use_case.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/use_cases/save_macro_goals_use_case.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_today_card.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_state.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_body_step.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_feature_row.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/onboarding_step_indicator.dart';
import 'package:vitta/main.dart';

import '../../../../factories/entities/body_weight_log_factory.dart';
import '../../../../fixtures/home_fixture.dart';
import '../../../../fixtures/local_storage_fixture.dart';
import '../../../../fixtures/premium_fixture.dart';
import '../../../../mocks/repositories_mocks.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

void main() {
  setUpAll(() async {
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(true);
    when(() => supabaseService.currentUserEmail).thenReturn(null);
    setupDependencies(appBox: await openTestHiveBox(), supabaseService: supabaseService);

    var hasSeenOnboarding = false;
    final onboardingRepository = MockOnboardingRepository();
    when(onboardingRepository.hasSeenOnboarding).thenAnswer((_) => hasSeenOnboarding);
    when(onboardingRepository.completeOnboarding).thenAnswer((_) async => hasSeenOnboarding = true);
    G.unregister<OnboardingRepository>();
    G.registerLazySingleton<OnboardingRepository>(() => onboardingRepository);
    registerTestPremiumCubit();
    registerTestHomeCubit();

    registerFallbackValue(MacroGoals.defaultGoals);
    final saveMacroGoalsUseCase = MockSaveMacroGoalsUseCase();
    when(() => saveMacroGoalsUseCase(any())).thenAnswer((_) async {});
    G.unregister<SaveMacroGoalsUseCase>();
    G.registerFactory<SaveMacroGoalsUseCase>(() => saveMacroGoalsUseCase);

    final logBodyWeightUseCase = MockLogBodyWeightUseCase();
    when(
      () => logBodyWeightUseCase(loggedDate: any(named: 'loggedDate'), weightKg: any(named: 'weightKg')),
    ).thenAnswer((_) async => Success(BodyWeightLogFactory.build()));
    G.unregister<LogBodyWeightUseCase>();
    G.registerFactory<LogBodyWeightUseCase>(() => logBodyWeightUseCase);

    registerFallbackValue(const BodyProfile());
    final saveBodyProfileUseCase = MockSaveBodyProfileUseCase();
    when(() => saveBodyProfileUseCase(any())).thenAnswer((_) async {});
    G.unregister<SaveBodyProfileUseCase>();
    G.registerFactory<SaveBodyProfileUseCase>(() => saveBodyProfileUseCase);
  });

  Future<void> advanceToAccountStep(WidgetTester tester) async {
    for (var step = 0; step < OnboardingState.stepCount - 1; step++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('opens on the welcome step, not on the account decision', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Vitta'), findsOneWidget);
    expect(find.byType(OnboardingStepIndicator), findsOneWidget);
    expect(find.text('Create account'), findsNothing);
  });

  testWidgets('walks welcome, the six areas, the body, goals and only then asks about an account', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingFeatureRow), findsNWidgets(6));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingBodyStep), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Suggested for'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('the body step suggests a target for the objective the user picks', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Lose weight'), 100, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Lose weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Suggested for Lose weight'), findsOneWidget);
  });

  testWidgets('skipping the body step jumps past goals and saves nothing', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('tapping create account opens the auth page without completing onboarding', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();
    await advanceToAccountStep(tester);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsWidgets);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('tapping the sign-in CTA opens the log in page without completing onboarding', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();
    await advanceToAccountStep(tester);

    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsWidgets);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('continuing without an account reaches home and persists the flag', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();
    await advanceToAccountStep(tester);

    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeTodayCard), findsOneWidget);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isTrue);
  });
}
