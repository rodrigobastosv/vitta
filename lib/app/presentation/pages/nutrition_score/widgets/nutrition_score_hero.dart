import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_macro_ring.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_score.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrition_labels.dart';

// A VTMacroRing rather than the band gauge the diet card uses: a score really is
// a single value against a single target, which is the ring's whole job. The
// gauge exists for a figure with a min and a max, and a score has neither.
class NutritionScoreHero extends StatelessWidget {
  const NutritionScoreHero({required this.score, super.key});

  static const double _maxPoints = 100;

  final NutritionScore score;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grade = score.grade;
    return Center(
      child: VTMacroRing(
        value: score.points / _maxPoints,
        color: grade.color,
        size: 168,
        strokeWidth: 14,
        child: Column(
          mainAxisSize: .min,
          children: [
            Text('${score.points}', style: VTTextStyles.display(context)),
            const VTGap.xs(),
            Text(
              grade.getLabel(l10n),
              style: VTTextStyles.bodyStrong(context).copyWith(color: grade.color),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
