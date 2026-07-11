import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTErrorState extends StatelessWidget {
  const VTErrorState({required this.message, this.onRetry, this.retryLabel = 'Try again', super.key});

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const VTGap.m(),
            Text(message, style: VTTextStyles.body(context), textAlign: .center),
            if (onRetry != null) ...[
              const VTGap.l(),
              VTPrimaryButton(label: retryLabel, icon: Icons.refresh, isExpanded: false, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
