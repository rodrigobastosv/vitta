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
    // The whole card carries the severity, not just an avatar on it. It used to
    // be `colorScheme.surface`, which is also `scaffoldBackgroundColor` - the
    // toast was the exact colour of the page behind it and only its shadow
    // separated the two.
    final container = severity.container(colorScheme);
    final ink = severity.onContainer(colorScheme);
    return Material(
      color: container,
      // A black shadow - Material's default - halos a coloured card in grey and
      // reads as a dirty border. The card's own colour is what separates it from
      // the page (dE 15.8 in light); the shadow only has to add depth, so it
      // does it in the card's hue instead of over it.
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
              // The accent, not the ink at a low alpha: the ink is near-black,
              // so diluting it over the card yields grey rather than a deeper
              // tone of the card's own hue.
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
                // The theme's primary green on a red card would read as a
                // different component sitting inside this one.
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
