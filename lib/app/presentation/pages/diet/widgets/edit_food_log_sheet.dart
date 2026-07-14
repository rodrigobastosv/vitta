import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';

Future<void> showEditFoodLogSheet({required BuildContext context, required FoodLogEntry entry}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<DietCubit>(), child: _EditFoodLogSheet(entry: entry)),
);

class _EditFoodLogSheet extends StatefulWidget {
  const _EditFoodLogSheet({required this.entry});

  final FoodLogEntry entry;

  @override
  State<_EditFoodLogSheet> createState() => _EditFoodLogSheetState();
}

class _EditFoodLogSheetState extends State<_EditFoodLogSheet> {
  late final UnitSystem _unitSystem = context.read<DietCubit>().unitSystem;
  late final TextEditingController _quantityController = TextEditingController(
    text: _formatNumber(_unitSystem.gramsToDisplayWeight(widget.entry.log.quantityGrams)),
  );
  late MealType _mealType = widget.entry.log.mealType;
  bool _isSaving = false;
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

  Future<void> _submit() async {
    final quantityDisplayValue = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    final l10n = context.l10n;
    if (quantityDisplayValue == null || quantityDisplayValue <= 0) {
      setState(() => _errorMessage = l10n.dietInvalidQuantity);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updatedResult = await context.read<DietCubit>().updateLog(
      logId: widget.entry.log.id,
      mealType: _mealType,
      quantityGrams: _unitSystem.displayWeightToGrams(quantityDisplayValue),
    );

    if (!mounted) {
      return;
    }
    updatedResult.when(
      (error) => setState(() {
        _isSaving = false;
        _errorMessage = error.message;
      }),
      (_) => Navigator.of(context).pop(),
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
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              VTFoodImage(imageUrl: widget.entry.food.imageUrl),
              const VTGap.m(),
              Expanded(child: Text(widget.entry.food.name, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.m(),
          TextField(
            controller: _quantityController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.dietQuantityLabel(_unitSystem.weightUnitLabel)),
          ),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              for (final mealType in MealType.values)
                ChoiceChip(
                  label: Text(mealType.getLabel(l10n)),
                  selected: _mealType == mealType,
                  onSelected: (_) => setState(() => _mealType = mealType),
                ),
            ],
          ),
          if (_errorMessage != null) ...[
            const VTGap.s(),
            Text(_errorMessage!, style: TextStyle(color: context.colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.saveAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
