import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTToast extends StatelessWidget {
  const VTToast({required this.title, required this.message, this.icon = Icons.check_circle_rounded, this.accentColor, super.key});

  final String title;
  final String message;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? VTColors.success;
    return Material(
      color: context.colorScheme.surface,
      elevation: 6,
      borderRadius: VTRadius.borderRadiusL,
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), shape: .circle),
              child: Icon(icon, color: accent, size: 24),
            ),
            const VTGap.m(),
            Expanded(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(title, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                  const VTGap.xs(),
                  Text(message, style: VTTextStyles.caption(context), maxLines: 2, overflow: .ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
