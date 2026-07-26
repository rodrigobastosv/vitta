import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/charts/vt_legend_dot.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/macro_gap.dart';

class MacroGapCard extends StatelessWidget {
  const MacroGapCard({required this.gap, super.key});

  final MacroGap gap;

  // The gap keeps its sign for the model, which needs to know a day is already
  // over; here it is floored at zero, because "-30 g of carbs left" is a figure
  // nobody reads as an amount. A day that is already met says so in words instead.
  int _left(double grams) => max(0, grams).round();

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
              Expanded(child: Text(l10n.mealSuggestionGapTitle, style: VTTextStyles.bodyStrong(context))),
              VTBadge(label: l10n.dietMealCalories(_left(gap.calories)), color: colorScheme.primary),
            ],
          ),
          const VTGap.xs(),
          Text(
            gap.isMet ? l10n.mealSuggestionGapMet : l10n.mealSuggestionGapMessage,
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.m,
            runSpacing: VTSpacing.s,
            children: [
              VTLegendDot(label: l10n.dietMacroGrams(_left(gap.protein).toString()), color: VTColors.macroProtein),
              VTLegendDot(label: l10n.dietMacroGrams(_left(gap.carbs).toString()), color: VTColors.macroCarbs),
              VTLegendDot(label: l10n.dietMacroGrams(_left(gap.fat).toString()), color: VTColors.macroFat),
              VTLegendDot(label: l10n.dietMacroGrams(_left(gap.fiber).toString()), color: VTColors.macroFiber),
            ],
          ),
        ],
      ),
    );
  }
}
