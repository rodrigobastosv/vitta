import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';
import 'package:vitta/app/presentation/general/food_image.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/initial_food_quantity.dart';

Future<RecipeIngredient?> showIngredientQuantitySheet({
  required BuildContext context,
  required Food food,
  required UnitSystem unitSystem,
}) => showModalBottomSheet<RecipeIngredient>(
  context: context,
  routeSettings: VTBottomSheet.ingredientQuantity.settings,
  isScrollControlled: true,
  builder: (sheetContext) => IngredientQuantitySheet(food: food, unitSystem: unitSystem),
);

class IngredientQuantitySheet extends StatefulWidget {
  const IngredientQuantitySheet({required this.food, required this.unitSystem, super.key});

  final Food food;
  final UnitSystem unitSystem;

  @override
  State<IngredientQuantitySheet> createState() => _IngredientQuantitySheetState();
}

class _IngredientQuantitySheetState extends State<IngredientQuantitySheet> {
  late final LoggedQuantity _initialQuantity = initialFoodQuantityFor(widget.food);
  late LoggedQuantity? _quantity = _initialQuantity;
  String? _errorMessage;

  // Reusing FoodQuantityInput is what gives a recipe "200 mL de leite" and
  // "2 ovos" for free: an ingredient is grams-only (RecipeIngredient
  // .quantityGrams), so whatever the cook types, the recipe stores the weight it
  // resolves to - which is the number the roll-up sums.
  void _submit() {
    final quantity = _quantity;
    if (quantity == null) {
      setState(() => _errorMessage = context.l10n.dietInvalidQuantity);
      return;
    }
    Navigator.of(context).pop(RecipeIngredient(food: widget.food, quantityGrams: quantity.grams));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              FoodImage(food: widget.food),
              const VTGap.m(),
              Expanded(child: Text(widget.food.name, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.m(),
          FoodQuantityInput(
            food: widget.food,
            unitSystem: widget.unitSystem,
            initialQuantity: _initialQuantity,
            autofocus: true,
            onChanged: (quantity) => _quantity = quantity,
          ),
          if (_errorMessage case final errorMessage?) ...[
            const VTGap.s(),
            Text(errorMessage, style: TextStyle(color: context.colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.dietRecipeAddIngredientAction, onPressed: _submit),
        ],
      ),
    );
  }
}
