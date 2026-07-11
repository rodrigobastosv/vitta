import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({required this.entry, required this.onDelete, super.key});

  final FoodLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return VTCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(entry.food.name, style: VTTextStyles.bodyStrong(context)),
                Text(
                  l10n.dietLogSubtitle(entry.log.quantityGrams.round(), entry.calories.round()),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.dietDeleteLogTooltip, onPressed: onDelete),
        ],
      ),
    );
  }
}
