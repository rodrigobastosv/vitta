import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/nutrient_score.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/nutrition_labels.dart';

class NutrientScoreTile extends StatelessWidget {
  const NutrientScoreTile({required this.score, super.key});

  static const double _avatarSize = 36;

  final NutrientScore score;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final accent = score.nutrient.color;
    return VTCard(
      child: Row(
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            alignment: .center,
            decoration: BoxDecoration(color: accent, shape: .circle),
            child: Icon(score.nutrient.icon, size: 20, color: VTColors.inkOn(accent)),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(score.nutrient.getLabel(l10n), style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                Text(
                  score.verdict.getLabel(l10n),
                  style: VTTextStyles.caption(context).copyWith(color: score.verdict.color, fontWeight: .w700),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
          const VTGap.s(),
          Flexible(
            child: FittedBox(
              fit: .scaleDown,
              child: Text(
                l10n.progressLabel(score.consumed.round().toString(), score.goal.round().toString(), score.nutrient.getUnitLabel(l10n)),
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
