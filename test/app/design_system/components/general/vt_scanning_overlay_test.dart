import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_scanning_overlay.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpOverlay(WidgetTester tester, {List<String> captions = const ['Scanning…'], bool reduceMotion = false}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: VTScanningOverlay(captions: captions)),
    ),
  ),
);

void main() {
  testWidgets('shows the first caption', (tester) async {
    await pumpOverlay(tester, captions: const ['Looking at your plate…', 'Estimating portions…']);
    await tester.pump();

    expect(find.text('Looking at your plate…'), findsOneWidget);
  });

  testWidgets('falls back to a scanner glyph when there is no photo', (tester) async {
    await pumpOverlay(tester);
    await tester.pump();

    expect(find.byIcon(Icons.center_focus_strong_outlined), findsOneWidget);
  });

  testWidgets('renders under reduce-motion without throwing', (tester) async {
    await pumpOverlay(tester, reduceMotion: true);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Scanning…'), findsOneWidget);
  });
}
