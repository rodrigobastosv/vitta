import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_labeled_slider.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_cubit.dart';
import 'package:vitta/app/presentation/pages/macro_goals/macro_goals_presentation_event.dart';
import 'package:vitta/app/presentation/pages/macro_goals/widgets/calorie_target_card.dart';

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
  late MacroGoals _goals = widget.initialGoals;

  static const double _maxProtein = 300;
  static const double _maxCarbs = 600;
  static const double _maxFat = 200;
  static const double _maxFiber = 100;

  Future<void> _submit() async {
    await widget.onSave(_goals);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _grams(double value) => '${value.round()} ${context.l10n.dietGramsUnit}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(VTSpacing.m),
      children: [
        CalorieTargetCard(goals: _goals, onCaloriesChanged: (calories) => setState(() => _goals = _goals.withScaledCalories(calories))),
        const VTGap.l(),
        VTLabeledSlider(
          label: l10n.dietProteinLabel,
          valueLabel: _grams(_goals.proteinGoalGrams),
          value: _goals.proteinGoalGrams,
          min: 0,
          max: _maxProtein,
          color: VTColors.macroProtein,
          onChanged: (grams) => setState(() => _goals = _goals.copyWith(proteinGoalGrams: grams)),
        ),
        const VTGap.m(),
        VTLabeledSlider(
          label: l10n.dietCarbsLabel,
          valueLabel: _grams(_goals.carbsGoalGrams),
          value: _goals.carbsGoalGrams,
          min: 0,
          max: _maxCarbs,
          color: VTColors.macroCarbs,
          onChanged: (grams) => setState(() => _goals = _goals.copyWith(carbsGoalGrams: grams)),
        ),
        const VTGap.m(),
        VTLabeledSlider(
          label: l10n.dietFatLabel,
          valueLabel: _grams(_goals.fatGoalGrams),
          value: _goals.fatGoalGrams,
          min: 0,
          max: _maxFat,
          color: VTColors.macroFat,
          onChanged: (grams) => setState(() => _goals = _goals.copyWith(fatGoalGrams: grams)),
        ),
        const VTGap.m(),
        VTLabeledSlider(
          label: l10n.dietFiberLabel,
          valueLabel: _grams(_goals.fiberGoalGrams),
          value: _goals.fiberGoalGrams,
          min: 0,
          max: _maxFiber,
          color: VTColors.macroFiber,
          onChanged: (grams) => setState(() => _goals = _goals.copyWith(fiberGoalGrams: grams)),
        ),
        const VTGap.l(),
        VTPrimaryButton(label: l10n.saveAction, onPressed: _submit),
      ],
    );
  }
}
