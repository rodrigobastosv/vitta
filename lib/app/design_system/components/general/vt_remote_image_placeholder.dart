import 'package:flutter/material.dart';

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
