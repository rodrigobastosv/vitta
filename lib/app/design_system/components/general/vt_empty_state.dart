import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTEmptyState extends StatelessWidget {
  const VTEmptyState({required this.message, this.icon = Icons.search_off, this.title, super.key});

  final String message;
  final String? title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(icon, size: 56, color: colorScheme.onSurfaceVariant),
            const VTGap.m(),
            if (title != null) ...[Text(title!, style: VTTextStyles.title(context), textAlign: .center), const VTGap.s()],
            Text(
              message,
              style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
