import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_scanning_overlay.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

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

  testWidgets('hides the page underneath completely', (tester) async {
    await pumpOverlay(tester);
    await tester.pump();

    // A scrim at 94% let the page behind bleed through, and on the meal scan its
    // "take a photo" CTA landed at exactly the caption's height — reading as a
    // pill the caption sat crooked inside (issue #235). Scoped to the overlay:
    // the Scaffold above it contributes its own (transparent) ColoredBox, which
    // is what `byType().first` would otherwise find.
    final scrim = tester.widget<ColoredBox>(find.descendant(of: find.byType(VTScanningOverlay), matching: find.byType(ColoredBox)).first);

    expect(scrim.color.a, 1);
    expect(scrim.color, VTTheme.light.colorScheme.surface);
  });

  testWidgets('keeps the longest caption off the screen edges', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The caption is otherwise unconstrained, so it lays out at the full screen
    // width and the longest one runs into both edges before it agrees to wrap.
    const longest = 'Extraindo as informações nutricionais…';
    await pumpOverlay(tester, captions: const [longest]);
    await tester.pump();

    final caption = tester.getRect(find.text(longest));

    expect(caption.left, greaterThanOrEqualTo(VTSpacing.l));
    expect(caption.right, lessThanOrEqualTo(320 - VTSpacing.l));
    expect(tester.takeException(), isNull);
  });
}
