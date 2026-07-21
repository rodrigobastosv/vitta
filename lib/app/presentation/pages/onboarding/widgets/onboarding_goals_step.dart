import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class OnboardingGoalsStep extends StatelessWidget {
  const OnboardingGoalsStep({required this.calorieGoal, required this.goals, required this.onChanged, super.key});

  static const double minCalories = 1200;
  static const double maxCalories = 4000;

  final double calorieGoal;
  final MacroGoals goals;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const VTGap.l(),
          Text(l10n.onboardingGoalsTitle, style: VTTextStyles.headline(context)),
          const VTGap.s(),
          Text(l10n.onboardingGoalsMessage, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
          const VTGap.xl(),
          Text('${calorieGoal.round()}', style: VTTextStyles.display(context)),
          Text(l10n.macroGoalsCalorieTargetTitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          const VTGap.m(),
          VTLabeledSlider(
            label: l10n.macroGoalsCalorieTargetTitle,
            valueLabel: '${calorieGoal.round()}',
            value: calorieGoal,
            min: minCalories,
            max: maxCalories,
            color: colorScheme.primary,
            onChanged: onChanged,
          ),
          const VTGap.l(),
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
              VTLegendDot(label: l10n.dietProteinLabel, color: VTColors.macroProtein),
              VTLegendDot(label: l10n.dietCarbsLabel, color: VTColors.macroCarbs),
              VTLegendDot(label: l10n.dietFatLabel, color: VTColors.macroFat),
            ],
          ),
          const VTGap.l(),
        ],
      ),
    );
  }
}
