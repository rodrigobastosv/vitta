import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_progress_bar.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrient_label.dart';

class MacroSummaryCard extends StatefulWidget {
  const MacroSummaryCard({required this.dailyMacros, required this.macroGoals, super.key});

  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  static double _progress(double consumed, double goal) => goal <= 0 ? 0 : consumed / goal;

  @override
  State<MacroSummaryCard> createState() => _MacroSummaryCardState();
}

class _MacroSummaryCardState extends State<MacroSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dailyMacros = widget.dailyMacros;
    final macroGoals = widget.macroGoals;
    final micronutrientTotals = dailyMacros.micronutrientTotals;
    final presentNutrients = Nutrient.values.where((nutrient) => (micronutrientTotals[nutrient] ?? 0) > 0).toList();
    final hasMicronutrients = presentNutrients.isNotEmpty;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.progressLabel(dailyMacros.totalCalories.round().toString(), macroGoals.calorieGoal.round().toString(), 'kcal'),
                  style: VTTextStyles.headline(context),
                ),
              ),
              if (hasMicronutrients)
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
                  tooltip: l10n.dietMicronutrientsTitle,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const VTGap.s(),
          VTProgressBar(value: MacroSummaryCard._progress(dailyMacros.totalCalories, macroGoals.calorieGoal)),
          const VTGap.m(),
          _MacroProgressRow(label: l10n.dietProteinLabel, consumed: dailyMacros.totalProtein, goal: macroGoals.proteinGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietCarbsLabel, consumed: dailyMacros.totalCarbs, goal: macroGoals.carbsGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietFatLabel, consumed: dailyMacros.totalFat, goal: macroGoals.fatGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietFiberLabel, consumed: dailyMacros.totalFiber, goal: macroGoals.fiberGoalGrams),
          if (hasMicronutrients && _isExpanded) ..._micronutrientSection(context, presentNutrients, micronutrientTotals),
        ],
      ),
    );
  }

  List<Widget> _micronutrientSection(BuildContext context, List<Nutrient> present, Map<Nutrient, double> totals) => [
    const VTGap.m(),
    const Divider(height: 1),
    const VTGap.m(),
    Text(context.l10n.dietMicronutrientsTitle, style: VTTextStyles.title(context)),
    const VTGap.s(),
    for (final nutrient in present) ...[
      _MicronutrientRow(nutrient: nutrient, gramsPer100g: totals[nutrient]!),
      const VTGap.xs(),
    ],
  ];
}

class _MicronutrientRow extends StatelessWidget {
  const _MicronutrientRow({required this.nutrient, required this.gramsPer100g});

  final Nutrient nutrient;
  final double gramsPer100g;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(nutrientLabel(l10n, nutrient), style: VTTextStyles.body(context)),
        Text(
          l10n.dietMicronutrientAmount(_formatAmount(nutrient.unit.fromGrams(gramsPer100g)), nutrient.unit.symbol),
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  static String _formatAmount(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }
}

class _MacroProgressRow extends StatelessWidget {
  const _MacroProgressRow({required this.label, required this.consumed, required this.goal});

  final String label;
  final double consumed;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(label, style: VTTextStyles.bodyStrong(context)),
            Text(
              l10n.progressLabel(consumed.round().toString(), goal.round().toString(), 'g'),
              style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const VTGap.s(),
        VTProgressBar(value: MacroSummaryCard._progress(consumed, goal), minHeight: 6),
      ],
    );
  }
}
