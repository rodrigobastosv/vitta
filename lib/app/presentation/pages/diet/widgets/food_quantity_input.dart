import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_selection.dart';

class FoodQuantityInput extends StatefulWidget {
  const FoodQuantityInput({
    required this.food,
    required this.unitSystem,
    required this.onChanged,
    this.initialGrams,
    this.initialUnits,
    this.autofocus = false,
    super.key,
  });

  final Food food;
  final UnitSystem unitSystem;
  final ValueChanged<FoodQuantitySelection> onChanged;
  final double? initialGrams;
  final double? initialUnits;
  final bool autofocus;

  @override
  State<FoodQuantityInput> createState() => _FoodQuantityInputState();
}

class _FoodQuantityInputState extends State<FoodQuantityInput> {
  late final TextEditingController _weightController;
  late final TextEditingController _unitsController;
  bool _syncing = false;
  late FoodQuantityMode _lastEdited;

  bool get _isCountable => widget.food.isCountable;

  @override
  void initState() {
    super.initState();
    final grams = widget.initialGrams;
    _weightController = TextEditingController(
      text: grams == null ? '' : QuantityFormat.format(widget.unitSystem.gramsToDisplayWeight(grams)),
    );
    final gramsPerUnit = widget.food.gramsPerUnit;
    final initialUnits = widget.initialUnits ?? (grams != null && gramsPerUnit != null ? grams / gramsPerUnit : null);
    _unitsController = TextEditingController(text: initialUnits == null ? '' : QuantityFormat.format(initialUnits));
    _lastEdited = widget.initialUnits != null ? .units : .weight;
    _weightController.addListener(_onWeightChanged);
    if (_isCountable) {
      _unitsController.addListener(_onUnitsChanged);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) => double.tryParse(controller.text.replaceAll(',', '.'));

  void _onWeightChanged() {
    if (_syncing) {
      return;
    }
    _lastEdited = .weight;
    final grams = FoodQuantityMode.weight.gramsFor(value: _parse(_weightController) ?? 0, food: widget.food, unitSystem: widget.unitSystem);
    final gramsPerUnit = widget.food.gramsPerUnit;
    if (_isCountable && gramsPerUnit != null) {
      _sync(_unitsController, grams == null ? '' : QuantityFormat.format(grams / gramsPerUnit));
    }
    _report();
  }

  void _onUnitsChanged() {
    if (_syncing) {
      return;
    }
    _lastEdited = .units;
    final grams = FoodQuantityMode.units.gramsFor(value: _parse(_unitsController) ?? 0, food: widget.food, unitSystem: widget.unitSystem);
    _sync(_weightController, grams == null ? '' : QuantityFormat.format(widget.unitSystem.gramsToDisplayWeight(grams)));
    _report();
  }

  void _sync(TextEditingController controller, String text) {
    _syncing = true;
    controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    _syncing = false;
  }

  void _report() {
    final mode = _lastEdited;
    final entered = _parse(mode == .units ? _unitsController : _weightController);
    if (entered == null || entered <= 0) {
      widget.onChanged(const FoodQuantitySelection());
      return;
    }
    widget.onChanged(
      FoodQuantitySelection(
        quantityGrams: mode.gramsFor(value: entered, food: widget.food, unitSystem: widget.unitSystem),
        quantityUnits: mode.unitsFor(entered),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_isCountable) {
      return _weightField(context, autofocus: widget.autofocus);
    }
    return Row(
      children: [
        Expanded(child: _weightField(context, autofocus: widget.autofocus)),
        const VTGap.m(),
        VTStepper(controller: _unitsController, suffixLabel: l10n.dietUnitsUnit),
      ],
    );
  }

  Widget _weightField(BuildContext context, {required bool autofocus}) => TextField(
    controller: _weightController,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: context.l10n.dietQuantityLabel(widget.unitSystem.weightUnitLabel)),
  );
}
