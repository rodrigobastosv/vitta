import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/main.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('vitta_test_hive');
    Hive.init(tempDir.path);
    final settingsBox = await Hive.openBox<dynamic>('settings_test');
    setupDependencies(settingsBox: settingsBox);
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

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Coming soon'), findsOneWidget);
  });
}
