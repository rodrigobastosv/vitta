import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/fitness_objective_icon.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/fitness_objective_label.dart';

class FitnessObjectiveTile extends StatelessWidget {
  const FitnessObjectiveTile({required this.objective, required this.isSelected, required this.onSelected, super.key});

  final FitnessObjective objective;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          VTHaptics.selection();
        }
        onSelected();
      },
      borderRadius: VTRadius.borderRadiusM,
      child: AnimatedContainer(
        duration: VTMotion.transition,
        curve: VTMotion.curve,
        padding: const EdgeInsets.all(VTSpacing.m),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: VTRadius.borderRadiusM,
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            // A solid disc with computed ink rather than the 16% accent tint,
            // which misses the 3:1 non-text floor for most accents.
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary,
              child: Icon(fitnessObjectiveIcon(objective), size: 20, color: VTColors.inkOn(colorScheme.primary)),
            ),
            const VTGap.m(),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    fitnessObjectiveLabel(l10n, objective),
                    style: VTTextStyles.bodyStrong(context).copyWith(color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
                  ),
                  Text(
                    fitnessObjectiveMessage(l10n, objective),
                    style: VTTextStyles.caption(context).copyWith(color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, size: 20, color: colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}
