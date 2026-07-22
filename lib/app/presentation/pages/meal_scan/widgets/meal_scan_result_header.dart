import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class MealScanResultHeader extends StatelessWidget {
  const MealScanResultHeader({required this.itemCount, required this.estimatedCalories, super.key});

  final int itemCount;
  final int estimatedCalories;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = context.colorScheme.primary;
    return VTCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accent,
            child: Icon(Icons.restaurant_rounded, color: VTColors.inkOn(accent), size: 22),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(l10n.mealScanFoundCount(itemCount), style: VTTextStyles.title(context)),
                Text(l10n.mealScanEstimatedTotal(estimatedCalories), style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
