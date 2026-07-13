import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';

class FoodLogTile extends StatelessWidget {
  const FoodLogTile({required this.entry, required this.onDelete, super.key});

  final FoodLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        VTFoodImage(imageUrl: entry.food.imageUrl),
        const VTGap.m(),
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
    );
  }
}
