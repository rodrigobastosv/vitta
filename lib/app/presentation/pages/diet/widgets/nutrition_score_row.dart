import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_score.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrition_labels.dart';

class NutritionScoreRow extends StatelessWidget {
  const NutritionScoreRow({required this.dailyMacros, required this.macroGoals, required this.onTap, super.key});

  final DailyMacros dailyMacros;
  final MacroGoals macroGoals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final score = NutritionScore.of(consumed: dailyMacros, goals: macroGoals);
    if (!score.isScorable) {
      return const SizedBox.shrink();
    }
    final grade = score.grade;
    return InkWell(
      onTap: onTap,
      borderRadius: VTRadius.borderRadiusM,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
        child: Row(
          children: [
            // A solid disc with inkOn rather than the accent on its own tint:
            // the figure is carried on the accent, which the contrast floor
            // rules out for a 16% tint.
            Container(
              width: 36,
              height: 36,
              alignment: .center,
              decoration: BoxDecoration(color: grade.color, shape: .circle),
              child: Text(
                '${score.points}',
                style: VTTextStyles.caption(context).copyWith(color: VTColors.inkOn(grade.color), fontWeight: .w700),
              ),
            ),
            const VTGap.s(),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(l10n.dietNutritionScoreTitle, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                  Text(
                    grade.getLabel(l10n),
                    style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
