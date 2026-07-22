import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// Names the destination day so the calendar below reads unambiguously as the source:
// meals flow from the day you pick into the day this banner states.
class CopyMealsTargetBanner extends StatelessWidget {
  const CopyMealsTargetBanner({required this.targetDate, super.key});

  final DateTime targetDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s + VTSpacing.xs),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: VTRadius.borderRadiusM),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, size: 20, color: colorScheme.onPrimaryContainer),
          const VTGap.s(),
          Expanded(
            child: Text(
              context.l10n.dietCopyMealsTargetBanner(context.materialLocalizations.formatFullDate(targetDate)),
              style: VTTextStyles.bodyStrong(context).copyWith(color: colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
