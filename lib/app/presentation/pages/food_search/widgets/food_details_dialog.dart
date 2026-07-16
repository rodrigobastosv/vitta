import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/micronutrient_row.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/macro_pill.dart';

Future<void> showFoodDetailsDialog({required BuildContext context, required Food food, required Object heroTag}) =>
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => FoodDetailsDialog(food: food, heroTag: heroTag),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    );

class FoodDetailsDialog extends StatelessWidget {
  const FoodDetailsDialog({required this.food, required this.heroTag, super.key});

  final Food food;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final presentNutrients = Nutrient.values.where((nutrient) => (food.micronutrientsPer100g[nutrient] ?? 0) > 0).toList();
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: .min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(VTSpacing.l),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Align(
                      child: Hero(
                        tag: heroTag,
                        child: VTFoodImage(imageUrl: food.imageUrl, size: 112),
                      ),
                    ),
                    const VTGap.m(),
                    Text(food.name, style: VTTextStyles.title(context), textAlign: .center),
                    if (food.brand case final brand?) ...[
                      const VTGap.xs(),
                      Text(
                        brand,
                        style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: .center,
                      ),
                    ],
                    const VTGap.xs(),
                    Text(l10n.dietCaloriesPer100g(food.caloriesPer100g.round()), style: VTTextStyles.body(context), textAlign: .center),
                    const VTGap.m(),
                    Wrap(
                      alignment: .center,
                      spacing: VTSpacing.s,
                      runSpacing: VTSpacing.xs,
                      children: [
                        MacroPill(label: l10n.dietProteinLabel, grams: food.proteinPer100g, color: VTColors.macroProtein),
                        MacroPill(label: l10n.dietCarbsLabel, grams: food.carbsPer100g, color: VTColors.macroCarbs),
                        MacroPill(label: l10n.dietFatLabel, grams: food.fatPer100g, color: VTColors.macroFat),
                        MacroPill(label: l10n.dietFiberLabel, grams: food.fiberPer100g, color: VTColors.macroFiber),
                      ],
                    ),
                    if (presentNutrients.isNotEmpty) ...[
                      const VTGap.m(),
                      const Divider(height: 1),
                      const VTGap.s(),
                      Text(l10n.dietNutritionPer100gTitle, style: VTTextStyles.caption(context)),
                      const VTGap.s(),
                      for (final nutrient in presentNutrients) ...[
                        MicronutrientRow(nutrient: nutrient, gramsPer100g: food.micronutrientsPer100g[nutrient]!),
                        const VTGap.xs(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
