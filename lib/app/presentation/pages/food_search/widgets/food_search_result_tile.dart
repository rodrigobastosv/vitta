import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class FoodSearchResultTile extends StatelessWidget {
  const FoodSearchResultTile({
    required this.food,
    required this.heroTag,
    required this.onTap,
    required this.onAdd,
    this.isFavorite = false,
    this.onToggleFavorite,
    super.key,
  });

  final Food food;
  final Object heroTag;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isFavorite;

  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          Hero(
            tag: heroTag,
            child: VTFoodImage(imageUrl: food.imageUrl),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(food.name, style: VTTextStyles.bodyStrong(context), maxLines: 2, overflow: .ellipsis),
                if (food.brand != null)
                  Text(
                    food.brand!,
                    style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                Text(
                  l10n.dietCaloriesPer100g(food.caloriesPer100g.round()),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (onToggleFavorite != null)
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              color: isFavorite ? VTColors.macroProtein : colorScheme.onSurfaceVariant,
              tooltip: isFavorite ? l10n.dietUnfavoriteFoodTooltip : l10n.dietFavoriteFoodTooltip,
            ),
          IconButton.filledTonal(onPressed: onAdd, icon: const Icon(Icons.add), tooltip: l10n.dietLogFoodAction),
        ],
      ),
    );
  }
}
