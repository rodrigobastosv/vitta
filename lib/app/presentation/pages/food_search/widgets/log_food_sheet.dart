import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_input.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

Future<void> showLogFoodSheet({required BuildContext context, required Food food, required DateTime loggedDate, MealType? initialMealType}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<FoodSearchCubit>(),
        child: _LogFoodSheet(food: food, loggedDate: loggedDate, initialMealType: initialMealType ?? MealType.breakfast),
      ),
    );

class _LogFoodSheet extends StatefulWidget {
  const _LogFoodSheet({required this.food, required this.loggedDate, required this.initialMealType});

  final Food food;
  final DateTime loggedDate;
  final MealType initialMealType;

  @override
  State<_LogFoodSheet> createState() => _LogFoodSheetState();
}

class _LogFoodSheetState extends State<_LogFoodSheet> {
  late final UnitSystem _unitSystem = context.read<FoodSearchCubit>().unitSystem;
  late final TextEditingController _quantityController = TextEditingController(
    text: QuantityFormat.format(_unitSystem.gramsToDisplayWeight(100)),
  );
  late MealType _mealType = widget.initialMealType;
  FoodQuantityMode _quantityMode = .weight;
  bool _isSaving = false;
  String? _errorMessage;

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
        : _quantityMode.valueIn(mode, value: entered, food: widget.food, unitSystem: _unitSystem);
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
        : _quantityMode.gramsFor(value: quantityDisplayValue, food: widget.food, unitSystem: _unitSystem);
    if (quantityDisplayValue == null || quantityDisplayValue <= 0 || quantityGrams == null) {
      setState(() => _errorMessage = l10n.dietInvalidQuantity);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final loggedResult = await context.read<FoodSearchCubit>().logFood(
      food: widget.food,
      loggedDate: widget.loggedDate,
      mealType: _mealType,
      quantityGrams: quantityGrams,
      quantityUnits: _quantityMode.unitsFor(quantityDisplayValue),
    );

    if (!mounted) {
      return;
    }
    loggedResult.when(
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
          Text(widget.food.name, style: VTTextStyles.title(context)),
          const VTGap.m(),
          FoodQuantityInput(
            food: widget.food,
            controller: _quantityController,
            mode: _quantityMode,
            onModeChanged: _quantityModeChanged,
            unitSystem: _unitSystem,
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
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.dietLogFoodAction, isLoading: _isSaving, onPressed: _submit),
        ],
      ),
    );
  }
}
