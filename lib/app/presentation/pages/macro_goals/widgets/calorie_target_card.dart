import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

/// The calorie hero of the macro-goals page (issue #116): the target derived
/// from the macros, its "on target" min/max band, the protein/carbs/fat energy
/// split, and a slider that scales the macros to hit a new calorie total. The
/// target is never edited directly - it's always the energy of the macros.
class CalorieTargetCard extends StatelessWidget {
  const CalorieTargetCard({required this.goals, required this.onCaloriesChanged, super.key});

  final MacroGoals goals;
  final ValueChanged<double> onCaloriesChanged;

  static const double _minCalories = 800;
  static const double _maxCalories = 5000;

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
              Text(l10n.macroGoalsKcal(goals.calorieGoal.round()), style: VTTextStyles.headline(context).copyWith(color: VTColors.green)),
            ],
          ),
          const VTGap.s(),
          // A bare themed slider, not a VTLabeledSlider: the header above is
          // already the value readout, so a labelled row would show the number
          // twice.
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: VTColors.green,
              thumbColor: VTColors.green,
              overlayColor: VTColors.green.withValues(alpha: 0.12),
              inactiveTrackColor: VTColors.green.withValues(alpha: 0.20),
              trackHeight: 4,
            ),
            child: Slider(
              value: goals.calorieGoal.clamp(_minCalories, _maxCalories),
              min: _minCalories,
              max: _maxCalories,
              onChanged: onCaloriesChanged,
            ),
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
