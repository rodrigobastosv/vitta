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
    onSurfaceVariant: VTColors.onSurfaceVariantLight,
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
    onSurfaceVariant: VTColors.onSurfaceVariantDark,
    outline: VTColors.outlineDark,
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.archivoTextTheme().copyWith(
      displayLarge: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -1),
      displayMedium: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -0.5),
      titleLarge: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -0.2),
      titleMedium: GoogleFonts.archivo(fontWeight: .w800, letterSpacing: -0.2),
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
        titleTextStyle: GoogleFonts.archivo(fontSize: 22, fontWeight: .w800, letterSpacing: -0.5, color: colorScheme.onSurface),
      ),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        // The fill was moved off secondaryContainer, but the ink was left behind:
        // a selected ChoiceChip still defaults its label to onSecondaryContainer
        // - coral - which then lands on a green fill. The ink is pinned to the
        // container it sits on so the pair travels together.
        // (An avatar icon can't be fixed here: RawChip merges chipTheme.iconTheme
        // into an IconTheme without resolving widget states, so a WidgetStateColor
        // would collapse to its fallback. A chip with an icon inks it itself.)
        // The sizing is Material's own labelLarge, restated because setting
        // labelStyle at all replaces the default rather than merging with it.
        labelStyle: (textTheme.labelLarge ?? const TextStyle()).copyWith(
          fontSize: 14,
          fontWeight: .w500,
          letterSpacing: 0.1,
          color: WidgetStateColor.fromMap({
            WidgetState.selected: colorScheme.onPrimaryContainer,
            WidgetState.any: colorScheme.onSurfaceVariant,
          }),
        ),
        shape: const StadiumBorder(),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusL),
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
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusFull),
          textStyle: GoogleFonts.archivo(fontSize: 15, fontWeight: .w800, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusFull),
          textStyle: GoogleFonts.archivo(fontSize: 15, fontWeight: .w800, letterSpacing: -0.2),
        ),
      ),
    );
  }
}
