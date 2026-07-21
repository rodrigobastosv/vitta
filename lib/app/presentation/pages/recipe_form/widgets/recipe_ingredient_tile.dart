import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

class RecipeIngredientTile extends StatelessWidget {
  const RecipeIngredientTile({required this.ingredient, required this.onRemove, super.key});

  final RecipeIngredient ingredient;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        VTFoodImage(imageUrl: ingredient.food.imageUrl),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(ingredient.food.name, style: VTTextStyles.bodyStrong(context)),
              Text(l10n.dietLogSubtitle(ingredient.quantityGrams.round(), ingredient.calories.round()), style: VTTextStyles.caption(context)),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close), tooltip: l10n.dietRecipeDeleteTooltip, onPressed: onRemove),
      ],
    );
  }
}
