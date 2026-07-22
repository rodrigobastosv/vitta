import 'package:flutter/material.dart';

class VTRemoteImagePlaceholder extends StatelessWidget {
  const VTRemoteImagePlaceholder({required this.colorScheme, required this.icon, required this.iconSize, this.tint, super.key});

  final ColorScheme colorScheme;
  final IconData icon;
  final double iconSize;

  // An accent for a food's category (issue #206); null keeps the neutral primary
  // placeholder every other image uses. Follows MealAvatar's tint-at-16%-behind-
  // its-own-icon convention so a category avatar reads as vividly as a meal one.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? colorScheme.primary;
    return ColoredBox(
      color: color.withValues(alpha: tint == null ? 0.08 : 0.16),
      child: Icon(icon, color: color.withValues(alpha: tint == null ? 0.45 : 1), size: iconSize),
    );
  }
}
