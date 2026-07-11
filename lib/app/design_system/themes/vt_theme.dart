import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';

abstract class VTTheme {
  static ThemeData get light => _buildTheme(_lightColorScheme);

  static ThemeData get dark => _buildTheme(_darkColorScheme);

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: .light,
    primary: VTColors.green,
    onPrimary: VTColors.onGreen,
    primaryContainer: VTColors.greenContainerLight,
    onPrimaryContainer: VTColors.onGreenContainerLight,
    secondary: VTColors.coral,
    onSecondary: VTColors.onCoral,
    secondaryContainer: VTColors.coralContainerLight,
    onSecondaryContainer: VTColors.onCoralContainerLight,
    tertiary: VTColors.success,
    onTertiary: VTColors.onGreen,
    error: VTColors.error,
    onError: VTColors.onError,
    errorContainer: VTColors.errorContainerLight,
    onErrorContainer: VTColors.onErrorContainerLight,
    surface: VTColors.surfaceLight,
    onSurface: VTColors.onSurfaceLight,
    surfaceContainerHighest: VTColors.surfaceContainerLight,
    onSurfaceVariant: VTColors.onSurfaceLight,
    outline: VTColors.outlineLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: .dark,
    primary: VTColors.greenLight,
    onPrimary: VTColors.onGreenDark,
    primaryContainer: VTColors.greenContainerDark,
    onPrimaryContainer: VTColors.onGreenContainerDark,
    secondary: VTColors.coralLight,
    onSecondary: VTColors.onCoralDark,
    secondaryContainer: VTColors.coralContainerDark,
    onSecondaryContainer: VTColors.onCoralContainerDark,
    tertiary: VTColors.success,
    onTertiary: VTColors.onGreen,
    error: VTColors.error,
    onError: VTColors.onError,
    errorContainer: VTColors.errorContainerDark,
    onErrorContainer: VTColors.onErrorContainerDark,
    surface: VTColors.surfaceDark,
    onSurface: VTColors.onSurfaceDark,
    surfaceContainerHighest: VTColors.surfaceContainerDark,
    onSurfaceVariant: VTColors.onSurfaceDark,
    outline: VTColors.outlineDark,
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: .w700),
      displayMedium: GoogleFonts.poppins(fontWeight: .w700),
      headlineLarge: GoogleFonts.poppins(fontWeight: .w700),
      headlineMedium: GoogleFonts.poppins(fontWeight: .w700),
      titleLarge: GoogleFonts.poppins(fontWeight: .w600),
      titleMedium: GoogleFonts.poppins(fontWeight: .w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme.apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: .w700, color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusM),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: const OutlineInputBorder(borderRadius: VTRadius.borderRadiusM, borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(borderRadius: VTRadius.borderRadiusM, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: VTRadius.borderRadiusM,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusM),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: .w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusM),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: .w700),
        ),
      ),
    );
  }
}
