import 'package:flutter/material.dart';

/// A faint primary tint rather than surfaceContainerHighest, which is close
/// enough to VTCard's own fill that the box disappears and the icon reads as
/// floating loose on the card. Low-contrast on purpose: a missing photo should
/// recede, not draw the eye away from what it illustrates.
class VTRemoteImagePlaceholder extends StatelessWidget {
  const VTRemoteImagePlaceholder({required this.colorScheme, required this.icon, required this.iconSize, super.key});

  final ColorScheme colorScheme;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: colorScheme.primary.withValues(alpha: 0.08),
    child: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.45), size: iconSize),
  );
}
