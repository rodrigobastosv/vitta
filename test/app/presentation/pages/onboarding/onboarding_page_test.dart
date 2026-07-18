import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/main.dart';

import '../../../../fixtures/local_storage_fixture.dart';
import '../../../../mocks/repositories_mocks.dart';
import '../../../../mocks/services_mocks.dart';

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
  });

  testWidgets('shows onboarding on first launch and tapping create account opens the auth page', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Vitta'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsWidgets);
    expect(find.byType(GridView), findsNothing);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('tapping the sign-in CTA opens the log in page without completing onboarding', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Already have an account? Log in'));
    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsWidgets);
    expect(find.byType(GridView), findsNothing);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('continuing without an account reaches home and persists the flag', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue without an account'));
    await tester.tap(find.text('Continue without an account'));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(G<OnboardingRepository>().hasSeenOnboarding(), isTrue);
  });
}
