import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/main.dart';

void main() {
  setUpAll(setupDependencies);

  testWidgets('renders the home page with its feature tiles and a settings action', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('navigates to the diet page when the diet tile is tapped', (tester) async {
    await tester.pumpWidget(const VittaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diet'));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
  });
}
