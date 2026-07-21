import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_quick_add_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_source_badge.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

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

  String subtitle(AppLocalizations l10n) {
    final calories = l10n.dietCaloriesPer100g(food.caloriesPer100g.round());
    return switch (food.brand) {
      final brand? when brand.trim().isNotEmpty => '$brand · $calories',
      _ => calories,
    };
  }

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
              mainAxisSize: .min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(food.name, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                    ),
                    if (food.source == FoodSource.recipe) ...[const VTGap.xs(), FoodSourceBadge(source: food.source)],
                  ],
                ),
                Text(
                  subtitle(l10n),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: .ellipsis,
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
          VTQuickAddButton(onPressed: onAdd, tooltip: l10n.dietLogFoodAction),
        ],
      ),
    );
  }
}
