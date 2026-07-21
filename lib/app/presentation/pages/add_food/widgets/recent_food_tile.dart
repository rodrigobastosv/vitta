import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/design_system/components/buttons/vt_quick_add_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class RecentFoodTile extends StatelessWidget {
  const RecentFoodTile({required this.entry, required this.onTap, required this.onQuickAdd, super.key});

  final FoodLogEntry entry;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  String _lastAmount(AppLocalizations l10n) => switch (entry.log.quantityUnits) {
    final units? => l10n.dietQuantityUnits(QuantityFormat.format(units)),
    null => l10n.dietQuantityGrams(entry.log.quantityGrams.round()),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return VTCard(
      onTap: onTap,
      child: Row(
        children: [
          VTFoodImage(imageUrl: entry.food.imageUrl),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(entry.food.name, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                Text(
                  '${_lastAmount(l10n)} · ${l10n.dietCaloriesLabel(entry.calories.round())}',
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ],
            ),
          ),
          VTQuickAddButton(onPressed: onQuickAdd, tooltip: l10n.dietLogAgainAction),
        ],
      ),
    );
  }
}
