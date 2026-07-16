import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_severity.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTToast extends StatelessWidget {
  const VTToast({required this.title, required this.message, this.severity = .success, this.actionLabel, this.onAction, super.key});

  final String title;
  final String message;
  final VTSeverity severity;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final container = severity.container(colorScheme);
    final ink = severity.onContainer(colorScheme);
    return Material(
      color: container,
      elevation: 3,
      shadowColor: severity.accent,
      shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusL),
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: severity.accent.withValues(alpha: 0.22), shape: .circle),
              child: Icon(severity.icon, color: ink, size: 24),
            ),
            const VTGap.m(),
            Expanded(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: VTTextStyles.bodyStrong(context).copyWith(color: ink),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  const VTGap.xs(),
                  Text(
                    message,
                    style: VTTextStyles.caption(context).copyWith(color: ink),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
            if (onAction case final onAction?) ...[
              const VTGap.s(),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: ink),
                child: Text(actionLabel ?? context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
