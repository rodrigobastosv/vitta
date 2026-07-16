import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';

Future<void> showLogSetSheet({
  required BuildContext context,
  required UnitSystem unitSystem,
  required Future<Result<VTError, void>> Function({required int reps, required double weightKg}) onSubmit,
  WorkoutSet? set,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: LogSetSheet(unitSystem: unitSystem, onSubmit: onSubmit, set: set),
  ),
);

class LogSetSheet extends StatefulWidget {
  const LogSetSheet({required this.unitSystem, required this.onSubmit, this.set, super.key});

  final UnitSystem unitSystem;
  final Future<Result<VTError, void>> Function({required int reps, required double weightKg}) onSubmit;
  final WorkoutSet? set;

  @override
  State<LogSetSheet> createState() => _LogSetSheetState();
}

class _LogSetSheetState extends State<LogSetSheet> {
  late final TextEditingController _repsController = TextEditingController(text: widget.set?.reps.toString() ?? '');
  late final TextEditingController _loadController = TextEditingController(text: _initialLoad());
  String? _errorMessage;

  String _initialLoad() {
    final set = widget.set;
    if (set == null || set.weightKg == 0) {
      return '';
    }
    final value = widget.unitSystem.kilogramsToDisplayLoad(set.weightKg);
    final rounded = value.round();
    return (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _repsController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(VTSpacing.l),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(widget.set == null ? l10n.workoutAddSet : l10n.workoutEditSet, style: VTTextStyles.title(context)),
          const VTGap.l(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repsController,
                  autofocus: true,
                  keyboardType: .number,
                  textInputAction: .next,
                  decoration: InputDecoration(labelText: l10n.workoutRepsLabel),
                ),
              ),
              const SizedBox(width: VTSpacing.m),
              Expanded(
                child: TextField(
                  controller: _loadController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: .done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(labelText: l10n.workoutLoadLabel(widget.unitSystem.loadUnitLabel)),
                ),
              ),
            ],
          ),
          const VTGap.s(),
          Text(l10n.workoutLoadHelper, style: VTTextStyles.caption(context)),
          if (_errorMessage case final message?) ...[
            const VTGap.s(),
            Text(message, style: VTTextStyles.caption(context).copyWith(color: colorScheme.error)),
          ],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.workoutLogSetAction, onPressed: _submit),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final reps = int.tryParse(_repsController.text.trim());
    if (reps == null || reps <= 0) {
      setState(() => _errorMessage = context.l10n.workoutInvalidRepsMessage);
      return;
    }
    final rawLoad = _loadController.text.trim().replaceAll(',', '.');
    final displayLoad = rawLoad.isEmpty ? 0.0 : double.tryParse(rawLoad);
    if (displayLoad == null || displayLoad < 0) {
      setState(() => _errorMessage = context.l10n.workoutInvalidLoadMessage);
      return;
    }

    final submittedResult = await widget.onSubmit(reps: reps, weightKg: widget.unitSystem.displayLoadToKilograms(displayLoad));
    if (!mounted) {
      return;
    }
    submittedResult.when((error) => setState(() => _errorMessage = error.message), (_) => Navigator.of(context).pop());
  }
}
