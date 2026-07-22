import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_quick_add_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/presentation/general/food_image.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class FoodResultTile extends StatelessWidget {
  const FoodResultTile({
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

  // The source tag rides on the meta line, not next to the name, so a badge word
  // ("Common"/"Recipe") can't shrink the name to an ellipsis (see issue #180). It
  // is inline colored text rather than a padded pill so every row keeps one
  // meta-line height and the list stays un-ragged.
  (String, Color)? _sourceTag(AppLocalizations l10n) => switch (food.source) {
    FoodSource.generic => (l10n.dietCommonFoodBadge, VTColors.green),
    FoodSource.recipe => (l10n.dietRecipeBadge, VTColors.macroFiber),
    _ => null,
  };

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
            child: FoodImage(food: food),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(food.name, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                Text.rich(
                  TextSpan(
                    style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                    children: [
                      if (_sourceTag(l10n) case (final label, final color))
                        TextSpan(text: '$label · ', style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700)),
                      TextSpan(text: subtitle(l10n)),
                    ],
                  ),
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
