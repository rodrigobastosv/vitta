import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/main.dart';

import 'fixtures/local_storage_fixture.dart';
import 'mocks/services_mocks.dart';

void main() {
  setUpAll(() async {
    setupDependencies(appBox: await openTestHiveBox(), supabaseService: MockSupabaseService());
    await G<OnboardingLocalDataSource>().markOnboardingSeen();
  });

  testWidgets('renders the home page with its feature tiles and a settings action', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('navigates to the workout page when the workout tile is tapped', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Workout'));
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
  });
}
