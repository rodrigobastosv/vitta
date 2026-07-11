import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class FoodSearchResultTile extends StatelessWidget {
  const FoodSearchResultTile({required this.food, required this.onTap, super.key});

  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return VTCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(food.name, style: VTTextStyles.bodyStrong(context)),
          if (food.brand != null) Text(food.brand!, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          Text(
            l10n.dietCaloriesPer100g(food.caloriesPer100g.round()),
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
