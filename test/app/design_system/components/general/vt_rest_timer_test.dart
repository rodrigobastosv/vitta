import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_rest_timer.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

double contrast(Color a, Color b) {
  final luminanceA = a.computeLuminance();
  final luminanceB = b.computeLuminance();
  return (math.max(luminanceA, luminanceB) + 0.05) / (math.min(luminanceA, luminanceB) + 0.05);
}

Future<void> pumpTimer(
  WidgetTester tester, {
  required Duration remaining,
  required double progress,
  ThemeData? theme,
  bool reduceMotion = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: VTRestTimer(
          remaining: remaining,
          progress: progress,
          onExtend: () {},
          onShorten: () {},
          onSkip: () {},
        ),
      ),
    ),
  ),
);

LinearGradient gradientOf(WidgetTester tester) {
  final decorated = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(VTRestTimer), matching: find.byType(DecoratedBox)).first,
  );
  return (decorated.decoration as BoxDecoration).gradient! as LinearGradient;
}

void main() {
  test('every point on both gradient stops stays readable against white ink', () {
    for (var step = 0; step <= 100; step++) {
      final progress = step / 100;
      final leadingRatio = contrast(VTRestTimer.colorAt(progress), VTColors.onGreen);
      final trailingRatio = contrast(VTRestTimer.trailingColorAt(progress), VTColors.onGreen);
      expect(leadingRatio, greaterThanOrEqualTo(4.5), reason: 'at ${(progress * 100).round()}% the leading stop is only ${leadingRatio.toStringAsFixed(2)}:1');
      expect(
        trailingRatio,
        greaterThanOrEqualTo(4.5),
        reason: 'at ${(progress * 100).round()}% the trailing stop is only ${trailingRatio.toStringAsFixed(2)}:1',
      );
    }
  });

  test('the ramp runs green, then amber, then red', () {
    expect(VTRestTimer.colorAt(1), VTColors.green);
    expect(VTRestTimer.colorAt(0.5), VTColors.warningStrong);
    expect(VTRestTimer.colorAt(0), VTColors.error);
  });

  test('the trailing stop lags the leading one, so the sweep has two colours to move between', () {
    expect(VTRestTimer.trailingColorAt(0.9), isNot(VTRestTimer.colorAt(0.9)));
    expect(VTRestTimer.trailingColorAt(0), VTColors.error, reason: 'the lag is clamped rather than running off the end of the ramp');
  });

  testWidgets('shows the remaining time in minutes and padded seconds', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 65), progress: 0.7);

    expect(find.text('1:05'), findsOneWidget);
  });

  testWidgets('no longer draws a progress bar, the colour carries it', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 30), progress: 0.3);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('paints a two-colour gradient in ${brightness.name}', (tester) async {
      await pumpTimer(
        tester,
        remaining: const Duration(seconds: 30),
        progress: 0.6,
        theme: brightness == .light ? VTTheme.light : VTTheme.dark,
      );

      final gradient = gradientOf(tester);
      expect(gradient.colors, contains(VTRestTimer.colorAt(0.6)));
      expect(gradient.colors, contains(VTRestTimer.trailingColorAt(0.6)));
      for (final color in gradient.colors) {
        expect(contrast(color, VTColors.onGreen), greaterThanOrEqualTo(4.5), reason: 'every stop carries the same ink');
      }
    });
  }

  testWidgets('sweeps horizontally, so the countdown reads as motion rather than a flat tint', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 30), progress: 0.6);
    final atRest = gradientOf(tester).begin;

    await tester.pump(VTRestTimer.sweep * 0.25);

    expect(gradientOf(tester).begin, isNot(atRest));
    expect((gradientOf(tester).begin as Alignment).y, 0, reason: 'the sweep travels sideways, never up the card');
  });

  testWidgets('holds still under reduce-motion', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 30), progress: 0.6, reduceMotion: true);
    final atRest = gradientOf(tester).begin;

    await tester.pump(VTRestTimer.sweep * 0.25);

    expect(gradientOf(tester).begin, atRest);
  });
}
