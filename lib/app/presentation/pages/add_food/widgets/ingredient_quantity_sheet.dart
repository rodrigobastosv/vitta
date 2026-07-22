import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/recipe_ingredient.dart';

Future<RecipeIngredient?> showIngredientQuantitySheet({required BuildContext context, required Food food, required UnitSystem unitSystem}) =>
    showModalBottomSheet<RecipeIngredient>(
      context: context,
      routeSettings: const RouteSettings(name: 'ingredientQuantitySheet'),
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
  late final TextEditingController _quantityController = TextEditingController(text: _formatNumber(widget.unitSystem.gramsToDisplayWeight(100)));
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    final rounded = double.parse(value.toStringAsFixed(1));
    return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
  }

  void _submit() {
    final quantityDisplayValue = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantityDisplayValue == null || quantityDisplayValue <= 0) {
      setState(() => _errorMessage = context.l10n.dietInvalidQuantity);
      return;
    }
    Navigator.of(context).pop(RecipeIngredient(food: widget.food, quantityGrams: widget.unitSystem.displayWeightToGrams(quantityDisplayValue)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(left: VTSpacing.m, right: VTSpacing.m, top: VTSpacing.m, bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTFoodImage(imageUrl: widget.food.imageUrl),
              const VTGap.m(),
              Expanded(child: Text(widget.food.name, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.m(),
          TextField(
            controller: _quantityController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.dietQuantityLabel(widget.unitSystem.weightUnitLabel)),
          ),
          if (_errorMessage case final errorMessage?) ...[const VTGap.s(), Text(errorMessage, style: TextStyle(color: context.colorScheme.error))],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.dietRecipeAddIngredientAction, onPressed: _submit),
        ],
      ),
    );
  }
}
