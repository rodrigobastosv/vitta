import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_score.dart';
import 'package:vitta/app/presentation/pages/nutrition_score/widgets/nutrient_score_tile.dart';
import 'package:vitta/app/presentation/pages/nutrition_score/widgets/nutrition_score_hero.dart';

/// How the whole day landed on all five targets, not just calories.
///
/// It has no cubit: `DietCubit` already holds the day's macros and goals, so
/// re-fetching them would be ceremony — the `DietDayPage` reasoning.
class NutritionScorePage extends StatelessWidget {
  const NutritionScorePage({required this.date, required this.dailyMacros, required this.macroGoals, super.key});

  final DateTime date;
  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final score = NutritionScore.of(consumed: dailyMacros, goals: macroGoals);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dietNutritionScoreTitle)),
      body: score.isScorable
          ? ListView(
              padding: const EdgeInsets.all(VTSpacing.m),
              children: [
                Center(
                  child: Text(
                    context.materialLocalizations.formatFullDate(date),
                    style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const VTGap.l(),
                NutritionScoreHero(score: score),
                const VTGap.l(),
                VTAppearEffect(
                  index: 1,
                  child: Text(l10n.dietNutritionScoreSubtitle, textAlign: .center, style: VTTextStyles.caption(context)),
                ),
                const VTGap.l(),
                Text(l10n.dietNutritionScoreMainNutrients, style: VTTextStyles.title(context)),
                const VTGap.s(),
                for (final (index, component) in score.scoredComponents.indexed) ...[
                  VTAppearEffect(index: index + 2, child: NutrientScoreTile(score: component)),
                  const VTGap.s(),
                ],
              ],
            )
          : VTEmptyState(icon: Icons.insights_outlined, title: l10n.dietNutritionScoreTitle, message: l10n.dietNutritionScoreEmpty),
    );
  }
}
