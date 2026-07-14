import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/calorie_pill.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_avatar.dart';

class CopyMealsMealTile extends StatelessWidget {
  const CopyMealsMealTile({required this.section, required this.isSelected, required this.onToggle, super.key});

  final MealSection section;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => onToggle(),
      controlAffinity: .leading,
      contentPadding: EdgeInsets.zero,
      secondary: CaloriePill(calories: section.totalCalories.round(), color: section.mealType.color),
      title: Row(
        children: [
          MealAvatar(icon: section.mealType.icon, color: section.mealType.color),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(section.mealType.getLabel(l10n), style: VTTextStyles.body(context)),
                Text(
                  l10n.dietCopyMealFoodCount(section.entries.length),
                  style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
