import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recipe_draft.dart';

class RecipeTotalsCard extends StatelessWidget {
  const RecipeTotalsCard({required this.draft, super.key});

  final RecipeDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.dietRecipeTotalsTitle, style: VTTextStyles.bodyStrong(context))),
              VTBadge(label: l10n.dietMealCalories(draft.totalCalories.round()), color: context.colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(l10n.dietRecipeTotalGrams(draft.totalGrams.round()), style: VTTextStyles.caption(context)),
          const VTGap.m(),
          VTDistributionBar(
            segments: [
              VTBarChartSegment(value: draft.totalProtein * 4, color: VTColors.macroProtein),
              VTBarChartSegment(value: draft.totalCarbs * 4, color: VTColors.macroCarbs),
              VTBarChartSegment(value: draft.totalFat * 9, color: VTColors.macroFat),
            ],
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.m,
            runSpacing: VTSpacing.s,
            children: [
              VTLegendDot(label: l10n.dietMacroGrams(draft.totalProtein.round().toString()), color: VTColors.macroProtein),
              VTLegendDot(label: l10n.dietMacroGrams(draft.totalCarbs.round().toString()), color: VTColors.macroCarbs),
              VTLegendDot(label: l10n.dietMacroGrams(draft.totalFat.round().toString()), color: VTColors.macroFat),
              VTLegendDot(label: l10n.dietMacroGrams(draft.totalFiber.round().toString()), color: VTColors.macroFiber),
            ],
          ),
          const VTGap.s(),
          Text(l10n.dietCaloriesPer100g(draft.per100g(draft.totalCalories).round()), style: VTTextStyles.caption(context)),
        ],
      ),
    );
  }
}
