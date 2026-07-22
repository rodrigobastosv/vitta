import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/components/inputs/vt_weight_picker.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/basal_metabolism.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/presentation/general/activity_level_selector.dart';
import 'package:vitta/app/presentation/general/age_slider.dart';
import 'package:vitta/app/presentation/general/basal_metabolism_card.dart';
import 'package:vitta/app/presentation/general/biological_sex_selector.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/fitness_objective_tile.dart';

class OnboardingBodyStep extends StatelessWidget {
  const OnboardingBodyStep({
    required this.unitSystem,
    required this.weightKg,
    required this.heightCm,
    required this.sex,
    required this.ageYears,
    required this.activityLevel,
    required this.metabolism,
    required this.objective,
    required this.onWeightChanged,
    required this.onHeightChanged,
    required this.onSexChanged,
    required this.onAgeChanged,
    required this.onActivityLevelChanged,
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
  final BiologicalSex? sex;
  final int ageYears;
  final ActivityLevel? activityLevel;
  final BasalMetabolism metabolism;
  final FitnessObjective objective;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<BiologicalSex> onSexChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<ActivityLevel> onActivityLevelChanged;
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
            step: unitSystem == .metric ? 0.1 : 0.2,
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
          // Sex, age and activity are what turn weight and height into a real
          // Mifflin-St Jeor figure (issue #169); each stays optional, and the
          // card below states when it is filling a gap with an assumption.
          BiologicalSexSelector(sex: sex, onChanged: onSexChanged),
          const VTGap.l(),
          AgeSlider(ageYears: ageYears, onChanged: onAgeChanged),
          const VTGap.l(),
          ActivityLevelSelector(activityLevel: activityLevel, onChanged: onActivityLevelChanged),
          const VTGap.l(),
          BasalMetabolismCard(metabolism: metabolism),
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
