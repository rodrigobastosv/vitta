import 'package:flutter/material.dart';

class VTPrimaryButton extends StatelessWidget {
  const VTPrimaryButton({required this.label, required this.onPressed, this.icon, this.isLoading = false, this.isExpanded = true, super.key});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.onPrimary))
        : Row(
            mainAxisSize: .min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final button = ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
