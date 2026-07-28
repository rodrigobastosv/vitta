import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_adjustable_slider.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_value_input_dialog.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class CalorieTargetCard extends StatelessWidget {
  const CalorieTargetCard({required this.goals, required this.onCaloriesChanged, super.key});

  final MacroGoals goals;
  final ValueChanged<double> onCaloriesChanged;

  static const double _minCalories = 800;
  static const double _maxCalories = 5000;

  // 50 kcal, because a calorie target is read and set in fifties - and because
  // the derived figure moves the three energy macros with it, so a finer step
  // would only add precision nobody expressed.
  static const double _calorieStep = 50;

  Future<void> _typeCalories(BuildContext context) async {
    final l10n = context.l10n;
    final typed = await showVTValueInputDialog(
      context: context,
      title: l10n.macroGoalsCalorieTargetTitle,
      value: goals.calorieGoal,
      min: _minCalories,
      max: _maxCalories,
      unitLabel: l10n.dietKcalUnit,
    );
    if (typed != null) {
      onCaloriesChanged(typed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: VTColors.green.withValues(alpha: 0.16),
                child: const Icon(Icons.local_fire_department, color: VTColors.green, size: 20),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.macroGoalsCalorieTargetTitle, style: VTTextStyles.bodyStrong(context)),
                    Text(
                      l10n.macroGoalsCalorieTargetHint,
                      style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
              const VTGap.s(),
              // The target is tappable for the same reason the macro badges are:
              // it moves in 50 kcal steps, so an exact figure has nowhere else to
              // be typed.
              Tooltip(
                message: l10n.adjustTypeValueAction(l10n.macroGoalsCalorieTargetTitle),
                child: InkWell(
                  onTap: () => _typeCalories(context),
                  borderRadius: VTRadius.borderRadiusM,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: VTSpacing.minTapTarget),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(l10n.macroGoalsKcal(goals.calorieGoal.round()), style: VTTextStyles.headline(context).copyWith(color: VTColors.green)),
                        // The glyph rides tight against the figure and stays at 12:
                        // a 24pt target plus a title and a hint already fills a
                        // 320px row, and the whole header overflows at 14 with a gap.
                        const Icon(Icons.edit_outlined, size: 12, color: VTColors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const VTGap.s(),
          VTAdjustableSlider(
            value: goals.calorieGoal,
            min: _minCalories,
            max: _maxCalories,
            step: _calorieStep,
            color: VTColors.green,
            onChanged: onCaloriesChanged,
            decreaseTooltip: l10n.adjustDecreaseAction(l10n.macroGoalsCalorieTargetTitle),
            increaseTooltip: l10n.adjustIncreaseAction(l10n.macroGoalsCalorieTargetTitle),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _Bound(label: l10n.macroGoalsCalorieMinLabel, value: l10n.macroGoalsKcal(goals.calorieMin.round())),
              _Bound(label: l10n.macroGoalsCalorieMaxLabel, value: l10n.macroGoalsKcal(goals.calorieMax.round()), alignEnd: true),
            ],
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
              VTLegendDot(label: l10n.dietProteinLabel, color: VTColors.macroProtein),
              VTLegendDot(label: l10n.dietCarbsLabel, color: VTColors.macroCarbs),
              VTLegendDot(label: l10n.dietFatLabel, color: VTColors.macroFat),
              VTLegendDot(label: l10n.dietFiberLabel, color: VTColors.macroFiber),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bound extends StatelessWidget {
  const _Bound({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: alignEnd ? .end : .start,
      children: [
        Text(label, style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurfaceVariant)),
        Text(value, style: VTTextStyles.caption(context)),
      ],
    );
  }
}
