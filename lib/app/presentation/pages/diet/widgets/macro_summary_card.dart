import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';

class MacroSummaryCard extends StatelessWidget {
  const MacroSummaryCard({required this.dailyMacros, super.key});

  final DailyMacros dailyMacros;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.dietCaloriesLabel(dailyMacros.totalCalories.round()), style: VTTextStyles.headline(context)),
          const VTGap.m(),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _MacroValue(label: l10n.dietProteinLabel, grams: dailyMacros.totalProtein),
              _MacroValue(label: l10n.dietCarbsLabel, grams: dailyMacros.totalCarbs),
              _MacroValue(label: l10n.dietFatLabel, grams: dailyMacros.totalFat),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({required this.label, required this.grams});

  final String label;
  final double grams;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text('${grams.round()}g', style: VTTextStyles.bodyStrong(context)),
        Text(label, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
