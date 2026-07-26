import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/text/quantity_format.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/logged_quantity.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_quantity_mode.dart';

class FoodQuantityInput extends StatefulWidget {
  const FoodQuantityInput({
    required this.food,
    required this.unitSystem,
    required this.initialQuantity,
    required this.onChanged,
    this.autofocus = false,
    super.key,
  });

  final Food food;
  final UnitSystem unitSystem;
  final LoggedQuantity initialQuantity;
  final ValueChanged<LoggedQuantity?> onChanged;
  final bool autofocus;

  @override
  State<FoodQuantityInput> createState() => _FoodQuantityInputState();
}

class _FoodQuantityInputState extends State<FoodQuantityInput> {
  late final FoodQuantityMode _measureMode = FoodQuantityMode.measureFor(widget.food);
  late final TextEditingController _measureController;
  late final TextEditingController _unitsController;
  bool _syncing = false;
  late FoodQuantityMode _lastEdited;

  bool get _isCountable => widget.food.isCountable;

  @override
  void initState() {
    super.initState();
    final grams = widget.initialQuantity.grams;
    _measureController = TextEditingController(
      text: _format(_measureMode.displayValueFor(grams: grams, food: widget.food, unitSystem: widget.unitSystem)),
    );
    _unitsController = TextEditingController(
      text: _format(
        widget.initialQuantity.units ??
            FoodQuantityMode.units.displayValueFor(grams: grams, food: widget.food, unitSystem: widget.unitSystem),
      ),
    );
    _lastEdited = widget.initialQuantity.units != null ? .units : _measureMode;
    _measureController.addListener(_onMeasureChanged);
    if (_isCountable) {
      _unitsController.addListener(_onUnitsChanged);
    }
  }

  @override
  void dispose() {
    _measureController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  String _format(double? value) => value == null ? '' : QuantityFormat.format(value);

  double? _parse(TextEditingController controller) => double.tryParse(controller.text.replaceAll(',', '.'));

  void _onMeasureChanged() {
    if (_syncing) {
      return;
    }
    _lastEdited = _measureMode;
    if (_isCountable) {
      _sync(_unitsController, FoodQuantityMode.units);
    }
    _report();
  }

  void _onUnitsChanged() {
    if (_syncing) {
      return;
    }
    _lastEdited = .units;
    _sync(_measureController, _measureMode);
    _report();
  }

  void _sync(TextEditingController controller, FoodQuantityMode mode) {
    final grams = _enteredQuantity()?.grams;
    final text = grams == null ? '' : _format(mode.displayValueFor(grams: grams, food: widget.food, unitSystem: widget.unitSystem));
    _syncing = true;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
  }

  LoggedQuantity? _enteredQuantity() {
    final mode = _lastEdited;
    final entered = _parse(mode == .units ? _unitsController : _measureController);
    if (entered == null || entered <= 0) {
      return null;
    }
    return mode.quantityFor(value: entered, food: widget.food, unitSystem: widget.unitSystem);
  }

  void _report() => widget.onChanged(_enteredQuantity());

  String get _measureUnitLabel => switch (_measureMode) {
    .volume => widget.unitSystem.volumeUnitLabel,
    _ => widget.unitSystem.weightUnitLabel,
  };

  @override
  Widget build(BuildContext context) {
    if (!_isCountable) {
      return _measureField(context, autofocus: widget.autofocus);
    }
    return Row(
      children: [
        VTStepper(controller: _unitsController, suffixLabel: context.l10n.dietUnitsUnit),
        const VTGap.m(),
        Expanded(child: _measureField(context, autofocus: widget.autofocus)),
      ],
    );
  }

  Widget _measureField(BuildContext context, {required bool autofocus}) => TextField(
    controller: _measureController,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: context.l10n.dietQuantityLabel(_measureUnitLabel)),
  );
}
