import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class ObjectiveTargetCard extends StatelessWidget {
  const ObjectiveTargetCard({required this.goals, required this.weightKg, required this.hasWeighIn, required this.unitSystem, super.key});

  final MacroGoals goals;
  final double weightKg;
  final bool hasWeighIn;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final weight = '${unitSystem.kilogramsToDisplayLoad(weightKg).toStringAsFixed(1)} ${unitSystem.loadUnitLabel}';
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.objectiveTargetTitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          Text('${goals.calorieGoal.round()}', style: VTTextStyles.display(context)),
          // Names the body the target was computed from, and says plainly when
          // that body is an assumption rather than a weigh-in - a number derived
          // from a default must not read as if it were measured.
          Text(
            hasWeighIn ? l10n.objectiveWeightFromLatest(weight) : l10n.objectiveWeightAssumed(weight),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const VTGap.m(),
          VTDistributionBar(
            segments: [
              VTBarChartSegment(value: goals.proteinGoalGrams * 4, color: VTColors.macroProtein),
              VTBarChartSegment(value: goals.carbsGoalGrams * 4, color: VTColors.macroCarbs),
              VTBarChartSegment(value: goals.fatGoalGrams * 9, color: VTColors.macroFat),
            ],
          ),
          const VTGap.s(),
          Wrap(
            spacing: VTSpacing.m,
            runSpacing: VTSpacing.xs,
            children: [
              VTLegendDot(label: '${l10n.dietProteinLabel} ${goals.proteinGoalGrams.round()}g', color: VTColors.macroProtein),
              VTLegendDot(label: '${l10n.dietCarbsLabel} ${goals.carbsGoalGrams.round()}g', color: VTColors.macroCarbs),
              VTLegendDot(label: '${l10n.dietFatLabel} ${goals.fatGoalGrams.round()}g', color: VTColors.macroFat),
            ],
          ),
        ],
      ),
    );
  }
}
