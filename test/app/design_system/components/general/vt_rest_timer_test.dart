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

Color rampAt(double progress) => switch (progress) {
  final value when value > 0.5 => Color.lerp(VTColors.warningStrong, VTColors.green, (value - 0.5) * 2)!,
  final value => Color.lerp(VTColors.error, VTColors.warningStrong, value * 2)!,
};

Future<void> pumpTimer(WidgetTester tester, {required Duration remaining, required double progress}) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VTRestTimer(
        remaining: remaining,
        progress: progress,
        onExtend: () {},
        onShorten: () {},
        onSkip: () {},
      ),
    ),
  ),
);

void main() {
  test('every point on the green to red ramp stays readable against white ink', () {
    for (var step = 0; step <= 100; step++) {
      final progress = step / 100;
      final ratio = contrast(rampAt(progress), VTColors.onGreen);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: 'at ${(progress * 100).round()}% the bar is only ${ratio.toStringAsFixed(2)}:1');
    }
  });

  test('the ramp runs green, then amber, then red', () {
    expect(rampAt(1), VTColors.green);
    expect(rampAt(0.5), VTColors.warningStrong);
    expect(rampAt(0), VTColors.error);
  });

  testWidgets('shows the remaining time in minutes and padded seconds', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 65), progress: 0.7);

    expect(find.text('1:05'), findsOneWidget);
  });

  testWidgets('no longer draws a progress bar, the colour carries it', (tester) async {
    await pumpTimer(tester, remaining: const Duration(seconds: 30), progress: 0.3);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
