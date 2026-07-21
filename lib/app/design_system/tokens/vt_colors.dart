import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract class VTColors {
  static const Color green = Color(0xFF2F7D52);
  static const Color greenLight = Color(0xFF6FBF97);
  static const Color onGreen = Color(0xFFFFFFFF);
  static const Color onGreenDark = Color(0xFF0D3322);
  static const Color greenContainerLight = Color(0xFFCFE6D0);
  static const Color greenContainerDark = Color(0xFF1F5C3F);
  static const Color onGreenContainerLight = Color(0xFF215B3B);
  static const Color onGreenContainerDark = Color(0xFFD9F2E4);

  static const Color coral = Color(0xFFE2622B);
  static const Color coralLight = Color(0xFFF2A278);
  static const Color onCoral = Color(0xFFFFFFFF);
  static const Color onCoralDark = Color(0xFF4A2410);
  static const Color coralContainerLight = Color(0xFFFBDCC7);
  static const Color coralContainerDark = Color(0xFF7A3A18);
  static const Color onCoralContainerLight = Color(0xFF5C2A0F);
  static const Color onCoralContainerDark = Color(0xFFFBDCC7);

  static const Color surfaceLight = Color(0xFFF6F5EC);
  static const Color surfaceDark = Color(0xFF141B17);
  static const Color onSurfaceLight = Color(0xFF201E1D);
  static const Color onSurfaceDark = Color(0xFFE7EFE9);
  static const Color onSurfaceVariantLight = Color(0xFF5F6B64);
  static const Color onSurfaceVariantDark = Color(0xFF9FB0A6);
  static const Color surfaceContainerLight = Color(0xFFF0EFE1);
  static const Color surfaceContainerDark = Color(0xFF1E2620);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1D2620);
  static const Color outlineLight = Color(0xFFE1DED0);
  static const Color outlineDark = Color(0xFF3A423C);

  static const Color macroProtein = Color(0xFFE2622B);
  static const Color macroCarbs = Color(0xFFE8A317);
  static const Color macroFat = Color(0xFF4F8DF6);
  static const Color macroFiber = Color(0xFF2F8F7A);

  static const Color bodyRegionChest = Color(0xFFE2622B);
  static const Color bodyRegionBack = Color(0xFF4F8DF6);
  static const Color bodyRegionShoulders = Color(0xFFE8A317);
  static const Color bodyRegionArms = Color(0xFF2F8F7A);
  static const Color bodyRegionCore = Color(0xFF8B5CF6);
  static const Color bodyRegionLegs = Color(0xFF2E7D5B);

  static const Color water = Color(0xFF2AA5D6);
  static const Color sleep = Color(0xFF5C6BC0);

  // Its own token rather than reusing macroCarbs/warning: a premium lock sits
  // next to macro figures on the diet page, and sharing a hex would read as a
  // fourth macro - the same collision bodyRegion* has to avoid.
  static const Color premium = Color(0xFFB8860B);

  static const Color success = Color(0xFF2F8F7A);
  static const Color warning = Color(0xFFE8A317);
  static const Color warningContainerLight = Color(0xFFFBECC7);
  static const Color warningContainerDark = Color(0xFF6B4E00);
  static const Color onWarningContainerLight = Color(0xFF3D2E00);
  static const Color onWarningContainerDark = Color(0xFFFBECC7);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerLight = Color(0xFF410002);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static Color inkOn(Color accent) => _contrast(accent, onGreen) >= _contrast(accent, onSurfaceLight) ? onGreen : onSurfaceLight;

  static double _contrast(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    return (math.max(luminanceA, luminanceB) + 0.05) / (math.min(luminanceA, luminanceB) + 0.05);
  }
}
