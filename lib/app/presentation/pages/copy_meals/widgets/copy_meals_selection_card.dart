import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/meal_section.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_meal_tile.dart';

class CopyMealsSelectionCard extends StatelessWidget {
  const CopyMealsSelectionCard({required this.meals, required this.selectedMealTypes, required this.onToggleMeal, super.key});

  final List<MealSection> meals;
  final Set<MealType> selectedMealTypes;
  final ValueChanged<MealType> onToggleMeal;

  @override
  Widget build(BuildContext context) => VTCard(
    child: Column(
      crossAxisAlignment: .start,
      children: [
        Text(context.l10n.dietCopyMealsSelectionTitle, style: VTTextStyles.title(context)),
        const VTGap.s(),
        for (final section in meals)
          CopyMealsMealTile(section: section, isSelected: selectedMealTypes.contains(section.mealType), onToggle: () => onToggleMeal(section.mealType)),
      ],
    ),
  );
}
