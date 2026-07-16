import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/presentation/pages/workout/workout_page.dart';
import 'package:vitta/main.dart';

import 'fixtures/local_storage_fixture.dart';
import 'mocks/services_mocks.dart';

void main() {
  setUpAll(() async {
    registerFallbackValue(SupabaseTable.workouts);
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.isAnonymous).thenReturn(true);
    when(() => supabaseService.currentUserEmail).thenReturn(null);
    when(() => supabaseService.currentUserId).thenReturn('user-1');
    when(() => supabaseService.from(any())).thenThrow(Exception('no Supabase backend in widget tests'));
    setupDependencies(appBox: await openTestHiveBox(), supabaseService: supabaseService);
    await G<OnboardingLocalDataSource>().markOnboardingSeen();
  });

  testWidgets('renders the home page with its feature tiles and a profile action', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('navigates to the workout page when the workout tile is tapped', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Workout'));
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutPage), findsOneWidget);
    expect(find.text('No workout logged'), findsOneWidget);
  });
}
