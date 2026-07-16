import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

Future<double?> showEditSleepGoalDialog({required BuildContext context, required double currentGoalHours}) => showDialog<double>(
  context: context,
  builder: (context) => _EditSleepGoalDialog(currentGoalHours: currentGoalHours),
);

class _EditSleepGoalDialog extends StatefulWidget {
  const _EditSleepGoalDialog({required this.currentGoalHours});

  final double currentGoalHours;

  @override
  State<_EditSleepGoalDialog> createState() => _EditSleepGoalDialogState();
}

class _EditSleepGoalDialogState extends State<_EditSleepGoalDialog> {
  late final TextEditingController _goalController = TextEditingController(text: _format(widget.currentGoalHours));
  String? _errorMessage;

  static String _format(double hours) => hours == hours.roundToDouble() ? hours.round().toString() : hours.toString();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _save() {
    final goalHours = double.tryParse(_goalController.text.replaceAll(',', '.'));
    if (goalHours == null || goalHours <= 0) {
      setState(() => _errorMessage = context.l10n.sleepGoalInvalid);
      return;
    }
    Navigator.of(context).pop(goalHours);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.sleepGoalDialogTitle),
      content: TextField(
        controller: _goalController,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.sleepGoalLabel, errorText: _errorMessage),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelAction)),
        TextButton(onPressed: _save, child: Text(l10n.saveAction)),
      ],
    );
  }
}
