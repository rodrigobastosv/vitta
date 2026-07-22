import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_quick_add_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';

class RecipeTile extends StatelessWidget {
  const RecipeTile({required this.recipe, required this.onEdit, required this.onDelete, required this.onLog, super.key});

  final Recipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTFoodImage(imageUrl: recipe.food.imageUrl),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(recipe.food.name, style: VTTextStyles.bodyStrong(context)),
                    const VTGap.xs(),
                    Text(l10n.dietRecipeIngredientCount(recipe.ingredients.length, recipe.totalGrams.round()), style: VTTextStyles.caption(context)),
                  ],
                ),
              ),
              const VTGap.s(),
              VTBadge(label: l10n.dietMealCalories(recipe.totalCalories.round()), color: context.colorScheme.primary),
              VTQuickAddButton(onPressed: onLog, tooltip: l10n.dietRecipeAddToMealAction),
              IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.dietRecipeDeleteTooltip, onPressed: onDelete),
            ],
          ),
          const VTGap.s(),
          Text(
            l10n.dietMealMacros(recipe.totalProtein.round(), recipe.totalCarbs.round(), recipe.totalFat.round(), recipe.totalFiber.round()),
            style: VTTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}
