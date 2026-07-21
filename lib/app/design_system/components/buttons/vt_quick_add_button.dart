import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

class VTQuickAddButton extends StatelessWidget {
  const VTQuickAddButton({required this.onPressed, required this.tooltip, super.key});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      tooltip: tooltip,
      style: IconButton.styleFrom(backgroundColor: colorScheme.primaryContainer, foregroundColor: colorScheme.onPrimaryContainer),
    );
  }
}
