import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

/// Owns the name controller, seeding it from the draft once. The cubit is the
/// source of truth for the value; this only exists because a TextField needs a
/// controller - the same split CustomFoodForm uses.
class RoutineNameField extends StatefulWidget {
  const RoutineNameField({required this.initialName, required this.onChanged, super.key});

  final String initialName;
  final ValueChanged<String> onChanged;

  @override
  State<RoutineNameField> createState() => _RoutineNameFieldState();
}

class _RoutineNameFieldState extends State<RoutineNameField> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textCapitalization: .sentences,
      decoration: InputDecoration(labelText: l10n.workoutRoutineNameLabel, hintText: l10n.workoutRoutineNameHint),
    );
  }
}
