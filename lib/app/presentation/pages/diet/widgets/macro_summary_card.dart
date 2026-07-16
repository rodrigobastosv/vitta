import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_progress_row.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/micronutrient_row.dart';

class MacroSummaryCard extends StatefulWidget {
  const MacroSummaryCard({required this.dailyMacros, required this.macroGoals, this.onEditGoals, super.key});

  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  /// Opens the goals editor. Null on the read-only history day view, where the
  /// same card is reused but goals aren't editable (the "pass no callback to
  /// disable" convention).
  final VoidCallback? onEditGoals;

  @override
  State<MacroSummaryCard> createState() => _MacroSummaryCardState();
}

class _MacroSummaryCardState extends State<MacroSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final dailyMacros = widget.dailyMacros;
    final macroGoals = widget.macroGoals;
    final micronutrientTotals = dailyMacros.micronutrientTotals;
    final presentNutrients = Nutrient.values.where((nutrient) => (micronutrientTotals[nutrient] ?? 0) > 0).toList();
    final hasMicronutrients = presentNutrients.isNotEmpty;
    final consumed = dailyMacros.totalCalories.round();
    final goal = macroGoals.calorieGoal.round();
    final difference = goal - consumed;
    final ringColor = dailyMacros.entries.isEmpty ? colorScheme.primary : dailyMacros.adherenceTo(macroGoals).color;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTMacroRing(
                value: _getProgress(dailyMacros.totalCalories, macroGoals.calorieGoal),
                color: ringColor,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text('$consumed', style: VTTextStyles.headline(context)),
                    Text(l10n.dietCaloriesOfGoal(goal), style: VTTextStyles.caption(context)),
                    const VTGap.xs(),
                    Text(
                      difference >= 0 ? l10n.dietCaloriesLeft(difference) : l10n.dietCaloriesOver(-difference),
                      style: VTTextStyles.overline(
                        context,
                      ).copyWith(color: difference >= 0 ? colorScheme.primary : VTColors.error, fontWeight: .w700),
                    ),
                  ],
                ),
              ),
              const VTGap.l(),
              Expanded(
                child: Column(
                  children: [
                    if (widget.onEditGoals != null)
                      Align(
                        alignment: .centerRight,
                        child: IconButton(
                          visualDensity: .compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.tune, size: 20),
                          tooltip: l10n.macroGoalsEditTooltip,
                          onPressed: widget.onEditGoals,
                        ),
                      ),
                    const VTGap.s(),
                    MacroProgressRow(
                      label: l10n.dietProteinLabel,
                      consumed: dailyMacros.totalProtein,
                      goal: macroGoals.proteinGoalGrams,
                      color: VTColors.macroProtein,
                    ),
                    const VTGap.s(),
                    MacroProgressRow(
                      label: l10n.dietCarbsLabel,
                      consumed: dailyMacros.totalCarbs,
                      goal: macroGoals.carbsGoalGrams,
                      color: VTColors.macroCarbs,
                    ),
                    const VTGap.s(),
                    MacroProgressRow(
                      label: l10n.dietFatLabel,
                      consumed: dailyMacros.totalFat,
                      goal: macroGoals.fatGoalGrams,
                      color: VTColors.macroFat,
                    ),
                    const VTGap.s(),
                    MacroProgressRow(
                      label: l10n.dietFiberLabel,
                      consumed: dailyMacros.totalFiber,
                      goal: macroGoals.fiberGoalGrams,
                      color: VTColors.macroFiber,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasMicronutrients) ...[
            const VTGap.m(),
            const Divider(height: 1),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
                label: Text(l10n.dietMicronutrientsTitle),
              ),
            ),
            if (_isExpanded) ..._micronutrientSection(context, presentNutrients, micronutrientTotals),
          ],
        ],
      ),
    );
  }

  double _getProgress(double consumed, double goal) => goal <= 0 ? 0 : consumed / goal;

  List<Widget> _micronutrientSection(BuildContext context, List<Nutrient> present, Map<Nutrient, double> totals) => [
    for (final nutrient in present) ...[MicronutrientRow(nutrient: nutrient, gramsPer100g: totals[nutrient]!), const VTGap.xs()],
  ];
}
