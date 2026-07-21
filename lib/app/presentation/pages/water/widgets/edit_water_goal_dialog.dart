import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';

Future<double?> showEditWaterGoalDialog({required BuildContext context, required double currentGoalMl, required UnitSystem unitSystem}) => showDialog<double>(
  context: context,
  builder: (context) => _EditWaterGoalDialog(currentGoalMl: currentGoalMl, unitSystem: unitSystem),
);

class _EditWaterGoalDialog extends StatefulWidget {
  const _EditWaterGoalDialog({required this.currentGoalMl, required this.unitSystem});

  final double currentGoalMl;
  final UnitSystem unitSystem;

  @override
  State<_EditWaterGoalDialog> createState() => _EditWaterGoalDialogState();
}

class _EditWaterGoalDialogState extends State<_EditWaterGoalDialog> {
  late final TextEditingController _goalController = TextEditingController(
    text: widget.unitSystem.millilitersToDisplayVolume(widget.currentGoalMl).round().toString(),
  );
  String? _errorMessage;

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _save() {
    final displayValue = double.tryParse(_goalController.text.replaceAll(',', '.'));
    final l10n = context.l10n;
    if (displayValue == null || displayValue <= 0) {
      setState(() => _errorMessage = l10n.waterInvalidAmount);
      return;
    }
    Navigator.of(context).pop(widget.unitSystem.displayVolumeToMilliliters(displayValue));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.waterGoalDialogTitle),
      content: TextField(
        controller: _goalController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.waterGoalLabel(widget.unitSystem.volumeUnitLabel), errorText: _errorMessage),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelAction)),
        TextButton(onPressed: _save, child: Text(l10n.saveAction)),
      ],
    );
  }
}
