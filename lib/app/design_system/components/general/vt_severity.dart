import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';

enum VTSeverity {
  success(icon: Icons.check_circle_rounded, accent: VTColors.success),
  warning(icon: Icons.info_rounded, accent: VTColors.warning),
  error(icon: Icons.error_rounded, accent: VTColors.error);

  const VTSeverity({required this.icon, required this.accent});

  final IconData icon;

  final Color accent;

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
