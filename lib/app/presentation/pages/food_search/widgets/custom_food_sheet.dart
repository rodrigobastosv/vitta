import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

Future<Food?> showCustomFoodSheet({required BuildContext context}) =>
    showModalBottomSheet<Food>(context: context, isScrollControlled: true, builder: (context) => const _CustomFoodSheet());

class _CustomFoodSheet extends StatefulWidget {
  const _CustomFoodSheet();

  @override
  State<_CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<_CustomFoodSheet> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double? _parse(String text) => double.tryParse(text.replaceAll(',', '.'));

  void _submit() {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final calories = _parse(_caloriesController.text);
    final protein = _parse(_proteinController.text);
    final carbs = _parse(_carbsController.text);
    final fat = _parse(_fatController.text);

    if (name.isEmpty || calories == null || protein == null || carbs == null || fat == null) {
      setState(() => _errorMessage = l10n.dietInvalidCustomFood);
      return;
    }

    Navigator.of(context).pop(
      Food(name: name, source: FoodSource.custom, caloriesPer100g: calories, proteinPer100g: protein, carbsPer100g: carbs, fatPer100g: fat),
    );
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(l10n.dietCustomFoodTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.dietFoodNameLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietCaloriesPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietProteinPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietCarbsPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietFatPer100gLabel),
            ),
            if (_errorMessage != null) ...[
              const VTGap.s(),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const VTGap.l(),
            VTPrimaryButton(label: l10n.dietContinueAction, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
