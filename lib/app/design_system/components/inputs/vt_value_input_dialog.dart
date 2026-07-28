import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';

/// Types an exact figure for a control that otherwise moves in steps.
///
/// A slider snaps to its step so a drag can only produce a round number, which
/// is what makes it usable — and it is also what puts 181 g out of reach on a
/// 5 g step. Typing is the only control that expresses an arbitrary value, so it
/// sits behind the value readout rather than replacing the slider.
///
/// A figure outside [min]/[max] is **rejected rather than clamped**: silently
/// returning a different number than the one typed teaches the user nothing
/// about the bound they just crossed.
Future<double?> showVTValueInputDialog({
  required BuildContext context,
  required String title,
  required double value,
  required double min,
  required double max,
  required String unitLabel,
}) => showDialog<double>(
  context: context,
  builder: (dialogContext) => _VTValueInputDialog(title: title, value: value, min: min, max: max, unitLabel: unitLabel),
);

class _VTValueInputDialog extends StatefulWidget {
  const _VTValueInputDialog({required this.title, required this.value, required this.min, required this.max, required this.unitLabel});

  final String title;
  final double value;
  final double min;
  final double max;
  final String unitLabel;

  @override
  State<_VTValueInputDialog> createState() => _VTValueInputDialogState();
}

class _VTValueInputDialogState extends State<_VTValueInputDialog> {
  late final TextEditingController _valueController = TextEditingController(text: widget.value.round().toString());
  bool _isOutOfRange = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String get _rangeMessage => context.l10n.adjustValueRange(widget.min.round().toString(), widget.max.round().toString());

  void _submit() {
    final typed = double.tryParse(_valueController.text.replaceAll(',', '.'));
    if (typed == null || typed < widget.min || typed > widget.max) {
      setState(() => _isOutOfRange = true);
      return;
    }
    Navigator.of(context).pop(typed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: VTTextField(
        controller: _valueController,
        label: widget.unitLabel,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: .done,
        autofocus: true,
        helperText: _rangeMessage,
        errorText: _isOutOfRange ? _rangeMessage : null,
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelAction)),
        TextButton(onPressed: _submit, child: Text(l10n.saveAction)),
      ],
    );
  }
}
