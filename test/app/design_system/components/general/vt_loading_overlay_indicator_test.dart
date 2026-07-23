import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpIndicator(WidgetTester tester, {bool reduceMotion = false}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: const Scaffold(body: VTLoadingOverlayIndicator()),
    ),
  ),
);

void main() {
  testWidgets('leads with the diet activity', (tester) async {
    await pumpIndicator(tester);
    await tester.pump();

    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });

  testWidgets('cycles through the activities while it waits', (tester) async {
    await pumpIndicator(tester);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsNothing);
  });

  testWidgets('holds on one activity under reduce-motion', (tester) async {
    await pumpIndicator(tester, reduceMotion: true);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_outlined), findsNothing);
  });

  testWidgets('cancels its rotation when it leaves the tree', (tester) async {
    await pumpIndicator(tester);
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox.shrink())));
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.takeException(), isNull);
  });
}
