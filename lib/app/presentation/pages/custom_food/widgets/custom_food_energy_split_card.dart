import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_bar_chart_segment.dart';
import 'package:vitta/app/design_system/components/charts/vt_distribution_bar.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_nutrient.dart';

class CustomFoodEnergySplitCard extends StatelessWidget {
  const CustomFoodEnergySplitCard({required this.nutrients, super.key});

  final Map<CustomFoodNutrient, double> nutrients;

  static const Map<CustomFoodNutrient, double> _caloriesPerGram = {.protein: 4, .carbs: 4, .fat: 9};

  static bool hasSplit(Map<CustomFoodNutrient, double> nutrients) =>
      _caloriesPerGram.keys.any((nutrient) => (nutrients[nutrient] ?? 0) > 0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shares = _shares();
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.dietEnergySplitTitle, style: VTTextStyles.bodyStrong(context))),
              VTBadge(
                label: l10n.dietMealCalories((nutrients[CustomFoodNutrient.calories] ?? 0).round()),
                color: context.colorScheme.primary,
              ),
            ],
          ),
          VTDistributionBar(
            segments: [
              for (final entry in shares.entries) VTBarChartSegment(value: entry.value, color: entry.key.getColor(context.colorScheme)),
            ],
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.m,
            runSpacing: VTSpacing.s,
            children: [for (final entry in shares.entries) _legend(context, nutrient: entry.key, share: entry.value)],
          ),
        ],
      ),
    );
  }

  Map<CustomFoodNutrient, double> _shares() {
    final energyByNutrient = {
      for (final entry in _caloriesPerGram.entries)
        if (nutrients[entry.key] case final grams? when grams > 0) entry.key: grams * entry.value,
    };
    final totalEnergy = energyByNutrient.values.fold<double>(0, (total, energy) => total + energy);
    return {for (final entry in energyByNutrient.entries) entry.key: entry.value / totalEnergy};
  }

  Widget _legend(BuildContext context, {required CustomFoodNutrient nutrient, required double share}) {
    final color = nutrient.getColor(context.colorScheme);
    return Row(
      mainAxisSize: .min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: .circle),
        ),
        const VTGap.s(),
        Text(nutrient.getLabel(context.l10n), style: VTTextStyles.caption(context)),
        const VTGap.xs(),
        Text(
          context.l10n.dietMacroPercent((share * 100).round()),
          style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
        ),
      ],
    );
  }
}
