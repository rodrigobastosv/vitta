import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

double contrast(Color a, Color b) {
  final luminanceA = a.computeLuminance();
  final luminanceB = b.computeLuminance();
  return (math.max(luminanceA, luminanceB) + 0.05) / (math.min(luminanceA, luminanceB) + 0.05);
}

void main() {
  const accents = {
    'water': VTColors.water,
    'coral': VTColors.coral,
    'green': VTColors.green,
    'sleep': VTColors.sleep,
    'success': VTColors.success,
    'macroProtein': VTColors.macroProtein,
    'macroCarbs': VTColors.macroCarbs,
    'macroFat': VTColors.macroFat,
    'macroFiber': VTColors.macroFiber,
    'error': VTColors.error,
    'warning': VTColors.warning,
    'premium': VTColors.premium,
  };

  test('inkOn clears the 3:1 non-text floor on every accent the app owns', () {
    for (final entry in accents.entries) {
      final ratio = contrast(entry.value, VTColors.inkOn(entry.value));
      expect(ratio, greaterThanOrEqualTo(3), reason: '${entry.key} icon on its own disc is only ${ratio.toStringAsFixed(2)}:1');
    }
  });

  test('inkOn picks the better of the two inks, never just the darker one', () {
    for (final entry in accents.entries) {
      final chosen = contrast(entry.value, VTColors.inkOn(entry.value));
      final other = VTColors.inkOn(entry.value) == VTColors.onGreen ? VTColors.onSurfaceLight : VTColors.onGreen;
      expect(chosen, greaterThanOrEqualTo(contrast(entry.value, other)), reason: '${entry.key} would read better on the other ink');
    }
  });

  test('a 16% tint under its own icon is exactly what inkOn exists to avoid', () {
    final tinted = Color.alphaBlend(VTColors.water.withValues(alpha: 0.16), VTColors.surfaceContainerLight);

    expect(contrast(VTColors.water, tinted), lessThan(3));
  });

  // The paywall wore the tinted-disc shortcut on its hero and every feature row
  // until this was measured: premium is not in the CLAUDE.md table but fails the
  // same way, and the paywall is the screen App Review looks hardest at.
  test('premium fails the tinted-disc shortcut and clears it as a solid disc', () {
    final tinted = Color.alphaBlend(VTColors.premium.withValues(alpha: 0.16), VTColors.cardLight);

    expect(contrast(VTColors.premium, tinted), lessThan(3));
    expect(contrast(VTColors.premium, VTColors.inkOn(VTColors.premium)), greaterThanOrEqualTo(4.5));
  });

  // Which is also why the highlighted feature row is a border and not coloured
  // text: premium as body text on a card misses AA outright.
  test('premium is not a text colour on a card', () {
    expect(contrast(VTColors.premium, VTColors.cardLight), lessThan(4.5));
  });
}
