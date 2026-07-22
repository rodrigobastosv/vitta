import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_progress_row.dart';

class HomeTodayCard extends StatelessWidget {
  const HomeTodayCard({required this.dailyMacros, required this.macroGoals, required this.onTap, super.key});

  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final consumed = dailyMacros.totalCalories.round();
    final goal = macroGoals.calorieGoal.round();
    final difference = goal - consumed;
    final hasEntries = dailyMacros.entries.isNotEmpty;
    final ringColor = hasEntries ? dailyMacros.adherenceTo(macroGoals).color : colorScheme.primary;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          VTCelebration(
            trigger: hasEntries && dailyMacros.adherenceTo(macroGoals) == .met,
            child: VTMacroRing(
              value: goal <= 0 ? 0 : consumed / goal,
              color: ringColor,
              size: 104,
              child: Column(
                mainAxisSize: .min,
                children: [
                  Text('$consumed', style: VTTextStyles.headline(context)),
                  Text(
                    difference >= 0 ? l10n.dietCaloriesLeft(difference) : l10n.dietCaloriesOver(-difference),
                    style: VTTextStyles.overline(
                      context,
                    ).copyWith(color: difference >= 0 ? colorScheme.onSurfaceVariant : VTColors.error, fontWeight: .w700),
                  ),
                ],
              ),
            ),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              spacing: VTSpacing.s,
              mainAxisSize: .min,
              children: [
                MacroProgressRow(
                  label: l10n.dietProteinLabel,
                  consumed: dailyMacros.totalProtein,
                  goal: macroGoals.proteinGoalGrams,
                  color: VTColors.macroProtein,
                ),
                MacroProgressRow(
                  label: l10n.dietCarbsLabel,
                  consumed: dailyMacros.totalCarbs,
                  goal: macroGoals.carbsGoalGrams,
                  color: VTColors.macroCarbs,
                ),
                MacroProgressRow(
                  label: l10n.dietFatLabel,
                  consumed: dailyMacros.totalFat,
                  goal: macroGoals.fatGoalGrams,
                  color: VTColors.macroFat,
                ),
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
    );
  }
}
