import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_food_image.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';

Future<void> showEditFoodLogSheet({required BuildContext context, required FoodLogEntry entry}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(
    value: context.read<DietCubit>(),
    child: _EditFoodLogSheet(entry: entry),
  ),
);

class _EditFoodLogSheet extends StatefulWidget {
  const _EditFoodLogSheet({required this.entry});

  final FoodLogEntry entry;

  @override
  State<_EditFoodLogSheet> createState() => _EditFoodLogSheetState();
}

class _EditFoodLogSheetState extends State<_EditFoodLogSheet> {
  late final UnitSystem _unitSystem = context.read<DietCubit>().unitSystem;

  late FoodQuantityMode _quantityMode = widget.entry.log.isLoggedInUnits && widget.entry.food.isCountable
      ? FoodQuantityMode.units
      : FoodQuantityMode.weight;
  late final TextEditingController _quantityController = TextEditingController(text: _initialQuantityText);
  late MealType _mealType = widget.entry.log.mealType;
  bool _isSaving = false;
  String? _errorMessage;

  String get _initialQuantityText => switch (_quantityMode) {
    .weight => QuantityFormat.format(_unitSystem.gramsToDisplayWeight(widget.entry.log.quantityGrams)),
    .units => QuantityFormat.format(widget.entry.log.quantityUnits!),
  };

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _quantityModeChanged(FoodQuantityMode mode) {
    if (mode == _quantityMode) {
      return;
    }
    final entered = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    final converted = entered == null
        ? null
        : _quantityMode.valueIn(mode, value: entered, food: widget.entry.food, unitSystem: _unitSystem);
    setState(() {
      _quantityMode = mode;
      if (converted != null) {
        _quantityController.text = QuantityFormat.format(converted);
      }
    });
  }

  Future<void> _submit() async {
    final quantityDisplayValue = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    final l10n = context.l10n;
    final quantityGrams = quantityDisplayValue == null
        ? null
        : _quantityMode.gramsFor(value: quantityDisplayValue, food: widget.entry.food, unitSystem: _unitSystem);
    if (quantityDisplayValue == null || quantityDisplayValue <= 0 || quantityGrams == null) {
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
      quantityGrams: quantityGrams,
      quantityUnits: _quantityMode.unitsFor(quantityDisplayValue),
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
          FoodQuantityInput(
            food: widget.entry.food,
            controller: _quantityController,
            mode: _quantityMode,
            onModeChanged: _quantityModeChanged,
            unitSystem: _unitSystem,
            autofocus: true,
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
          if (_errorMessage != null) ...[const VTGap.s(), Text(_errorMessage!, style: TextStyle(color: context.colorScheme.error))],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.saveAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
