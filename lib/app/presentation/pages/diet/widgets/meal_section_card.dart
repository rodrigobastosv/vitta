import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/calorie_pill.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_log_tile.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/meal_avatar.dart';

class MealSectionCard extends StatefulWidget {
  const MealSectionCard({required this.section, required this.onAddFood, required this.onDeleteEntry, super.key});

  final MealSection section;
  final VoidCallback? onAddFood;
  final void Function(FoodLogEntry entry) onDeleteEntry;

  @override
  State<MealSectionCard> createState() => _MealSectionCardState();
}

class _MealSectionCardState extends State<MealSectionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final section = widget.section;
    return VTCard(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              MealAvatar(icon: section.mealType.icon, color: section.mealType.color),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(section.mealType.getLabel(l10n), style: VTTextStyles.title(context)),
                    const VTGap.xs(),
                    Text(
                      l10n.dietMealMacros(
                        section.totalProtein.round(),
                        section.totalCarbs.round(),
                        section.totalFat.round(),
                        section.totalFiber.round(),
                      ),
                      style: VTTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
              const VTGap.s(),
              CaloriePill(calories: section.totalCalories.round(), color: section.mealType.color),
              Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
            ],
          ),
          if (_isExpanded) ...[
            const VTGap.m(),
            for (final entry in section.entries) ...[
              FoodLogTile(entry: entry, onDelete: () => widget.onDeleteEntry(entry)),
              const VTGap.s(),
            ],
            if (widget.onAddFood != null)
              Align(
                alignment: .centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onAddFood,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.dietAddToMeal(section.mealType.getLabel(l10n))),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
