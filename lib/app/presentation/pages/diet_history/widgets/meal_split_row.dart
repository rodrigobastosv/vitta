import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';

class MealSplitRow extends StatelessWidget {
  const MealSplitRow({required this.mealType, required this.share, required this.dailyAverage, super.key});

  final MealType mealType;
  final double share;
  final double dailyAverage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Icon(mealType.icon, size: 18, color: mealType.color),
        const VTGap.s(),
        Expanded(child: Text(mealType.getLabel(l10n), style: VTTextStyles.caption(context))),
        Text(
          l10n.dietMealSplitAverage(dailyAverage.round()),
          style: VTTextStyles.caption(context),
        ),
        const VTGap.s(),
        VTBadge(label: l10n.dietMacroPercent((share * 100).round()), color: mealType.color),
      ],
    );
  }
}
