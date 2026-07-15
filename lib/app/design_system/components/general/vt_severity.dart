import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

/// How loud a `VTToast` should be. `error` is a failure the user did not cause
/// (the network, a write that didn't land); `warning` is one they can fix from
/// where they already are - an empty field is not a crash and should not wear a
/// crash's colours.
enum VTSeverity {
  success(icon: Icons.check_circle_rounded, accent: VTColors.success),
  warning(icon: Icons.info_rounded, accent: VTColors.warning),
  error(icon: Icons.error_rounded, accent: VTColors.error);

  const VTSeverity({required this.icon, required this.accent});

  final IconData icon;

  /// Tints the disc behind the icon. It has to be the saturated accent, never
  /// the ink at a low alpha: `onErrorContainer` is a near-black red, so 10% of
  /// it over the pink card came out muddy grey - that dilutes black, not red.
  final Color accent;

  /// The toast's card. A container tone with its own ink over it - never one
  /// accent used as both a 16% disc and the glyph on top of it, which measures
  /// 1.85:1 for amber on light and 2.52:1 for error on dark because both sides
  /// of the pair are the same colour. These pairs are 6.6:1 or better in every
  /// combination, in both themes.
  Color container(ColorScheme colorScheme) => switch (this) {
    .success => colorScheme.primaryContainer,
    .warning => colorScheme.brightness == .light ? VTColors.warningContainerLight : VTColors.warningContainerDark,
    .error => colorScheme.errorContainer,
  };

  Color onContainer(ColorScheme colorScheme) => switch (this) {
    .success => colorScheme.onPrimaryContainer,
    .warning => colorScheme.brightness == .light ? VTColors.onWarningContainerLight : VTColors.onWarningContainerDark,
    .error => colorScheme.onErrorContainer,
  };
}
