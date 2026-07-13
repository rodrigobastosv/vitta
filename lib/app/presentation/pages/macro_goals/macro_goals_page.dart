import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_presentation_event.dart';

class MacroGoalsPage extends StatelessWidget {
  const MacroGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<MacroGoalsCubit, MacroGoals, MacroGoalsPresentationEvent>(
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.macroGoalsTitle)),
        body: _MacroGoalsForm(initialGoals: state, onSave: cubit.saveGoals),
      ),
    );
  }
}

class _MacroGoalsForm extends StatefulWidget {
  const _MacroGoalsForm({required this.initialGoals, required this.onSave});

  final MacroGoals initialGoals;
  final Future<void> Function(MacroGoals goals) onSave;

  @override
  State<_MacroGoalsForm> createState() => _MacroGoalsFormState();
}

class _MacroGoalsFormState extends State<_MacroGoalsForm> {
  late final _calorieController = TextEditingController(text: widget.initialGoals.calorieGoal.round().toString());
  late final _proteinController = TextEditingController(text: widget.initialGoals.proteinGoalGrams.round().toString());
  late final _carbsController = TextEditingController(text: widget.initialGoals.carbsGoalGrams.round().toString());
  late final _fatController = TextEditingController(text: widget.initialGoals.fatGoalGrams.round().toString());
  late final _fiberController = TextEditingController(text: widget.initialGoals.fiberGoalGrams.round().toString());
  String? _errorMessage;

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  double? _parse(String text) => double.tryParse(text.replaceAll(',', '.'));

  Future<void> _submit() async {
    final l10n = context.l10n;
    final calorieGoal = _parse(_calorieController.text);
    final proteinGoalGrams = _parse(_proteinController.text);
    final carbsGoalGrams = _parse(_carbsController.text);
    final fatGoalGrams = _parse(_fatController.text);
    final fiberGoalGrams = _parse(_fiberController.text);

    final goals = [calorieGoal, proteinGoalGrams, carbsGoalGrams, fatGoalGrams, fiberGoalGrams];
    if (goals.any((goal) => goal == null || goal <= 0)) {
      setState(() => _errorMessage = l10n.macroGoalsInvalid);
      return;
    }

    await widget.onSave(
      MacroGoals(
        calorieGoal: calorieGoal!,
        proteinGoalGrams: proteinGoalGrams!,
        carbsGoalGrams: carbsGoalGrams!,
        fatGoalGrams: fatGoalGrams!,
        fiberGoalGrams: fiberGoalGrams!,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(VTSpacing.m),
      children: [
        TextField(
          controller: _calorieController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.macroGoalsCalorieLabel),
        ),
        const VTGap.s(),
        TextField(
          controller: _proteinController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.macroGoalsProteinLabel),
        ),
        const VTGap.s(),
        TextField(
          controller: _carbsController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.macroGoalsCarbsLabel),
        ),
        const VTGap.s(),
        TextField(
          controller: _fatController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.macroGoalsFatLabel),
        ),
        const VTGap.s(),
        TextField(
          controller: _fiberController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.macroGoalsFiberLabel),
        ),
        if (_errorMessage != null) ...[const VTGap.s(), Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
        const VTGap.l(),
        VTPrimaryButton(label: l10n.saveAction, onPressed: _submit),
      ],
    );
  }
}
