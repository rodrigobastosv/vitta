import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_progress_bar.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class MacroSummaryCard extends StatelessWidget {
  const MacroSummaryCard({required this.dailyMacros, required this.macroGoals, super.key});

  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.progressLabel(dailyMacros.totalCalories.round().toString(), macroGoals.calorieGoal.round().toString(), 'kcal'),
            style: VTTextStyles.headline(context),
          ),
          const VTGap.s(),
          VTProgressBar(value: _progress(dailyMacros.totalCalories, macroGoals.calorieGoal)),
          const VTGap.m(),
          _MacroProgressRow(label: l10n.dietProteinLabel, consumed: dailyMacros.totalProtein, goal: macroGoals.proteinGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietCarbsLabel, consumed: dailyMacros.totalCarbs, goal: macroGoals.carbsGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietFatLabel, consumed: dailyMacros.totalFat, goal: macroGoals.fatGoalGrams),
          const VTGap.s(),
          _MacroProgressRow(label: l10n.dietFiberLabel, consumed: dailyMacros.totalFiber, goal: macroGoals.fiberGoalGrams),
        ],
      ),
    );
  }

  static double _progress(double consumed, double goal) => goal <= 0 ? 0 : consumed / goal;
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
