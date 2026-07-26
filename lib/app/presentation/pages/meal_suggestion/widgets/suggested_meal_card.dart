import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/meal_suggestions.dart';

// One option, picked by tapping it. Selection reads from the primary border and
// tint alone - no check glyph - the same call the diet modality cards make.
class SuggestedMealCard extends StatelessWidget {
  const SuggestedMealCard({required this.meal, required this.isSelected, required this.onTap, super.key});

  final SuggestedMeal meal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == .dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08) : (isDark ? VTColors.cardDark : VTColors.cardLight),
        borderRadius: VTRadius.borderRadiusL,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        type: .transparency,
        borderRadius: VTRadius.borderRadiusL,
        child: InkWell(
          onTap: onTap,
          borderRadius: VTRadius.borderRadiusL,
          child: Padding(
            padding: const EdgeInsets.all(VTSpacing.m),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(child: Text(meal.name, style: VTTextStyles.bodyStrong(context))),
                    const VTGap.s(),
                    VTBadge(label: l10n.dietMealCalories(meal.totalCalories.round()), color: colorScheme.primary),
                  ],
                ),
                if (meal.summary.isNotEmpty) ...[
                  const VTGap.xs(),
                  Text(meal.summary, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
                ],
                const VTGap.m(),
                VTDistributionBar(
                  segments: [
                    VTBarChartSegment(value: meal.totalProtein * 4, color: VTColors.macroProtein),
                    VTBarChartSegment(value: meal.totalCarbs * 4, color: VTColors.macroCarbs),
                    VTBarChartSegment(value: meal.totalFat * 9, color: VTColors.macroFat),
                  ],
                ),
                const VTGap.s(),
                Wrap(
                  spacing: VTSpacing.m,
                  runSpacing: VTSpacing.xs,
                  children: [
                    VTLegendDot(label: l10n.dietMacroGrams(meal.totalProtein.round().toString()), color: VTColors.macroProtein),
                    VTLegendDot(label: l10n.dietMacroGrams(meal.totalCarbs.round().toString()), color: VTColors.macroCarbs),
                    VTLegendDot(label: l10n.dietMacroGrams(meal.totalFat.round().toString()), color: VTColors.macroFat),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
