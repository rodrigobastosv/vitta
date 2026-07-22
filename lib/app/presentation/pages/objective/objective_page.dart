import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/app/presentation/general/activity_level_selector.dart';
import 'package:vitta/app/presentation/general/age_slider.dart';
import 'package:vitta/app/presentation/general/basal_metabolism_card.dart';
import 'package:vitta/app/presentation/general/biological_sex_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/objective/objective_cubit.dart';
import 'package:vitta/app/presentation/pages/objective/objective_presentation_event.dart';
import 'package:vitta/app/presentation/pages/objective/objective_state.dart';
import 'package:vitta/app/presentation/pages/objective/widgets/objective_target_card.dart';
import 'package:vitta/app/presentation/pages/onboarding/widgets/fitness_objective_tile.dart';

class ObjectivePage extends StatelessWidget {
  const ObjectivePage({super.key});

  static const double minHeightCm = 120;
  static const double maxHeightCm = 220;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ObjectiveCubit, ObjectiveState, ObjectivePresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case ObjectiveShowLoading():
            context.showLoading();
          case ObjectiveHideLoading():
            context.hideLoading();
          case ObjectiveSaved():
            context.showToast(title: l10n.objectiveSavedTitle, message: l10n.objectiveSavedMessage);
            Navigator.of(context).pop();
        }
      },
      builder: (context, cubit, state) {
        final colorScheme = context.colorScheme;
        final unitSystem = cubit.unitSystem;
        final displayHeight = unitSystem.centimetersToDisplayHeight(state.heightCm);
        final goals = state.goals;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.objectiveTitle)),
          body: ListView(
            padding: const EdgeInsets.all(VTSpacing.m),
            children: [
              Text(l10n.objectiveMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
              const VTGap.l(),
              for (final option in FitnessObjective.values) ...[
                FitnessObjectiveTile(objective: option, isSelected: option == state.objective, onSelected: () => cubit.objectiveChanged(option)),
                const VTGap.s(),
              ],
              const VTGap.m(),
              VTLabeledSlider(
                label: l10n.onboardingHeightLabel,
                valueLabel: '${displayHeight.round()} ${unitSystem.heightUnitLabel}',
                value: displayHeight,
                min: unitSystem.centimetersToDisplayHeight(minHeightCm),
                max: unitSystem.centimetersToDisplayHeight(maxHeightCm),
                color: colorScheme.primary,
                onChanged: (value) => cubit.heightChanged(unitSystem.displayHeightToCentimeters(value)),
              ),
              const VTGap.l(),
              BiologicalSexSelector(sex: state.sex, onChanged: cubit.sexChanged),
              const VTGap.l(),
              AgeSlider(ageYears: state.ageYears, onChanged: cubit.ageChanged),
              const VTGap.l(),
              ActivityLevelSelector(activityLevel: state.activityLevel, onChanged: cubit.activityLevelChanged),
              const VTGap.l(),
              // The estimate is shown where it is decided: the calorie target
              // below is this figure times the objective's factor, so seeing the
              // two together is what makes the target explainable.
              BasalMetabolismCard(metabolism: state.metabolism),
              const VTGap.l(),
              if (goals != null) ...[
                ObjectiveTargetCard(goals: goals, weightKg: state.weightKg, hasWeighIn: state.hasWeighIn, unitSystem: unitSystem),
                const VTGap.l(),
              ],
              // Switching objective rewrites the macro goals, so the page says so
              // before the user commits rather than letting them discover it on
              // the diet page.
              Text(l10n.objectiveOverwritesGoalsNote, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              const VTGap.m(),
              VTPrimaryButton(label: l10n.objectiveSaveAction, onPressed: state.canSave ? cubit.saveObjective : null),
            ],
          ),
        );
      },
    );
  }
}
