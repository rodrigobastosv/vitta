import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutSetActions extends StatelessWidget {
  const WorkoutSetActions({required this.accent, this.onAddSet, this.onRepeatSet, super.key});

  final Color accent;
  final VoidCallback? onAddSet;
  final VoidCallback? onRepeatSet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        if (onAddSet != null)
          Expanded(
            child: FilledButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(l10n.workoutAddSet),
              style: FilledButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.14),
                foregroundColor: accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusM),
                textStyle: VTTextStyles.bodyStrong(context),
              ),
            ),
          ),
        if (onRepeatSet != null) ...[
          const VTGap.s(),
          TextButton.icon(
            onPressed: onRepeatSet,
            icon: const Icon(Icons.repeat_rounded, size: 18),
            label: Text(l10n.workoutRepeatSetAction),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: 12),
              shape: const RoundedRectangleBorder(borderRadius: VTRadius.borderRadiusM),
              textStyle: VTTextStyles.bodyStrong(context),
            ),
          ),
        ],
      ],
    );
  }
}
