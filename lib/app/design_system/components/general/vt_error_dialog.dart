import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

class VTErrorDialog extends StatelessWidget {
  const VTErrorDialog({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      icon: Icon(Icons.error_outline, color: context.colorScheme.error),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(l10n.retry),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ok)),
      ],
    );
  }
}
