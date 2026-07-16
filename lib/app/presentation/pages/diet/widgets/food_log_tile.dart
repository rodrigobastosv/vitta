import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({required this.entry, this.onEdit, this.onDelete, super.key});

  final FoodLogEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// A log the user counted reads back as the count they typed; everything else
  /// reads as grams, exactly as before.
  String _subtitle(AppLocalizations l10n) => switch (entry.log.quantityUnits) {
    final units? => l10n.dietLogSubtitleUnits(QuantityFormat.format(units), entry.calories.round()),
    null => l10n.dietLogSubtitle(entry.log.quantityGrams.round(), entry.calories.round()),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onEdit,
      borderRadius: VTRadius.borderRadiusS,
      child: Row(
        children: [
          VTFoodImage(imageUrl: entry.food.imageUrl),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(entry.food.name, style: VTTextStyles.bodyStrong(context)),
                Text(_subtitle(l10n), style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.dietDeleteLogTooltip, onPressed: onDelete),
        ],
      ),
    );
  }
}
