import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/components/inputs/vt_weight_picker.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/fitness_objective_tile.dart';

class OnboardingBodyStep extends StatelessWidget {
  const OnboardingBodyStep({
    required this.unitSystem,
    required this.weightKg,
    required this.heightCm,
    required this.objective,
    required this.onWeightChanged,
    required this.onHeightChanged,
    required this.onObjectiveChanged,
    super.key,
  });

  static const double minWeightKg = 30;
  static const double maxWeightKg = 250;
  static const double minHeightCm = 120;
  static const double maxHeightCm = 220;

  final UnitSystem unitSystem;
  final double weightKg;
  final double heightCm;
  final FitnessObjective objective;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<FitnessObjective> onObjectiveChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final displayHeight = unitSystem.centimetersToDisplayHeight(heightCm);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const VTGap.l(),
          Text(l10n.onboardingBodyTitle, style: VTTextStyles.headline(context)),
          const VTGap.s(),
          Text(l10n.onboardingBodyMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
          const VTGap.l(),
          Text(l10n.onboardingWeightLabel, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          // The same ruler the body weight page logs with, because this reading
          // becomes the app's first body weight entry - not a separate control
          // for a separate kind of number.
          VTWeightPicker(
            initialValue: unitSystem.kilogramsToDisplayLoad(weightKg),
            onChanged: (value) => onWeightChanged(unitSystem.displayLoadToKilograms(value)),
            unitLabel: unitSystem.loadUnitLabel,
            min: unitSystem.kilogramsToDisplayLoad(minWeightKg),
            max: unitSystem.kilogramsToDisplayLoad(maxWeightKg),
            step: unitSystem == UnitSystem.metric ? 0.1 : 0.2,
          ),
          const VTGap.l(),
          // Height is a slider rather than a second ruler: it is set once and
          // never revisited, so a whole unit of precision is enough and the step
          // stays one screen tall.
          VTLabeledSlider(
            label: l10n.onboardingHeightLabel,
            valueLabel: '${displayHeight.round()} ${unitSystem.heightUnitLabel}',
            value: displayHeight,
            min: unitSystem.centimetersToDisplayHeight(minHeightCm),
            max: unitSystem.centimetersToDisplayHeight(maxHeightCm),
            color: colorScheme.primary,
            onChanged: (value) => onHeightChanged(unitSystem.displayHeightToCentimeters(value)),
          ),
          const VTGap.l(),
          Text(l10n.onboardingObjectiveTitle, style: VTTextStyles.bodyStrong(context)),
          const VTGap.s(),
          for (final option in FitnessObjective.values) ...[
            FitnessObjectiveTile(objective: option, isSelected: option == objective, onSelected: () => onObjectiveChanged(option)),
            const VTGap.s(),
          ],
          const VTGap.m(),
        ],
      ),
    );
  }
}
