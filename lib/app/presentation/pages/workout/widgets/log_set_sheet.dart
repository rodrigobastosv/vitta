import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_stepper.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/labelled_field.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/set_prefill.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> showLogSetSheet({
  required BuildContext context,
  required UnitSystem unitSystem,
  required Future<Result<VTError, void>> Function({required SetInput input}) onSubmit,
  bool isCardio = false,
  WorkoutSet? set,
  double? defaultLoadKg,
  int? defaultReps,
  int? defaultDurationSeconds,
  double? defaultDistanceMeters,
  SetPrefill prefill = SetPrefill.none,
}) => showModalBottomSheet<void>(
  context: context,
  routeSettings: VTBottomSheet.logSet.settings,
  isScrollControlled: true,
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: LogSetSheet(
      unitSystem: unitSystem,
      onSubmit: onSubmit,
      isCardio: isCardio,
      set: set,
      defaultLoadKg: defaultLoadKg,
      defaultReps: defaultReps,
      defaultDurationSeconds: defaultDurationSeconds,
      defaultDistanceMeters: defaultDistanceMeters,
      prefill: prefill,
    ),
  ),
);

class LogSetSheet extends StatefulWidget {
  const LogSetSheet({
    required this.unitSystem,
    required this.onSubmit,
    this.isCardio = false,
    this.set,
    this.defaultLoadKg,
    this.defaultReps,
    this.defaultDurationSeconds,
    this.defaultDistanceMeters,
    this.prefill = SetPrefill.none,
    super.key,
  });

  final UnitSystem unitSystem;
  final Future<Result<VTError, void>> Function({required SetInput input}) onSubmit;

  // Whether the exercise is cardio (treadmill, bike, ...): its set is logged as
  // duration + optional distance rather than reps + load.
  final bool isCardio;

  final WorkoutSet? set;

  // Pre-fills the load for a *new* set - the user's latest body weight on a
  // bodyweight exercise (issue #101). Ignored when editing an existing set.
  final double? defaultLoadKg;

  // Pre-fills the reps for a *new* set from the previous one, so the stepper
  // starts where the last set left off rather than at the minimum.
  final int? defaultReps;

  // Pre-fill for a *new* cardio set from the previous one.
  final int? defaultDurationSeconds;
  final double? defaultDistanceMeters;

  // Where the prefilled numbers came from, so the hint can say so truthfully.
  final SetPrefill prefill;

  @override
  State<LogSetSheet> createState() => _LogSetSheetState();
}

class _LogSetSheetState extends State<LogSetSheet> {
  static const int _defaultReps = 10;

  late final TextEditingController _repsController = TextEditingController(text: '${widget.set?.reps ?? widget.defaultReps ?? _defaultReps}');
  late final TextEditingController _loadController = TextEditingController(text: _initialLoad());
  late final TextEditingController _minutesController = TextEditingController(text: _initialMinutes());
  late final TextEditingController _secondsController = TextEditingController(text: _initialSeconds());
  late final TextEditingController _distanceController = TextEditingController(text: _initialDistance());
  String? _errorMessage;

  String _hint(AppLocalizations l10n) {
    if (widget.isCardio) {
      return l10n.workoutDistanceOptionalHelper;
    }
    return switch (widget.set == null ? widget.prefill : SetPrefill.none) {
      SetPrefill.lastSet => l10n.workoutLastSetPrefillNote,
      SetPrefill.bodyWeight => l10n.workoutBodyweightPrefillNote,
      SetPrefill.none => l10n.workoutLoadHelper,
    };
  }

  int? get _seededDurationSeconds => widget.set?.durationSeconds ?? (widget.set == null ? widget.defaultDurationSeconds : null);

  String _initialMinutes() {
    final seconds = _seededDurationSeconds;
    return seconds == null ? '' : '${seconds ~/ 60}';
  }

  String _initialSeconds() {
    final seconds = _seededDurationSeconds;
    if (seconds == null || seconds % 60 == 0) {
      return '';
    }
    return '${seconds % 60}';
  }

  String _initialDistance() {
    final meters = widget.set?.distanceMeters ?? (widget.set == null ? widget.defaultDistanceMeters : null);
    if (meters == null || meters == 0) {
      return '';
    }
    return _formatDecimal(widget.unitSystem.metersToDisplayDistance(meters));
  }

  String _initialLoad() {
    final set = widget.set;
    final loadKg = set != null ? set.weightKg : (widget.defaultLoadKg ?? 0);
    if (loadKg == 0) {
      return '';
    }
    return _formatDecimal(widget.unitSystem.kilogramsToDisplayLoad(loadKg));
  }

  String _formatDecimal(double value) {
    final rounded = value.round();
    return (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _repsController.dispose();
    _loadController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _distanceController.dispose();
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
          if (widget.isCardio) _cardioFields(l10n) else _strengthFields(l10n),
          const VTGap.s(),
          Text(_hint(l10n), style: VTTextStyles.caption(context)),
          if (_errorMessage case final message?) ...[const VTGap.s(), Text(message, style: VTTextStyles.caption(context).copyWith(color: colorScheme.error))],
          const VTGap.l(),
          VTPrimaryButton(label: l10n.workoutLogSetAction, onPressed: _submit),
        ],
      ),
    );
  }

  Widget _strengthFields(AppLocalizations l10n) => Row(
    crossAxisAlignment: .start,
    children: [
      Expanded(
        child: LabelledField(label: l10n.workoutRepsLabel, child: VTStepper(controller: _repsController)),
      ),
      const SizedBox(width: VTSpacing.m),
      Expanded(
        child: LabelledField(
          label: l10n.workoutLoadLabel(widget.unitSystem.loadUnitLabel),
          child: TextField(
            controller: _loadController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: .done,
            onSubmitted: (_) => _submit(),
          ),
        ),
      ),
    ],
  );

  Widget _cardioFields(AppLocalizations l10n) => Column(
    crossAxisAlignment: .start,
    children: [
      Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: LabelledField(
              label: l10n.workoutDurationMinutesLabel,
              child: TextField(controller: _minutesController, keyboardType: TextInputType.number, textInputAction: .next),
            ),
          ),
          const SizedBox(width: VTSpacing.m),
          Expanded(
            child: LabelledField(
              label: l10n.workoutDurationSecondsLabel,
              child: TextField(controller: _secondsController, keyboardType: TextInputType.number, textInputAction: .next),
            ),
          ),
        ],
      ),
      const VTGap.m(),
      LabelledField(
        label: l10n.workoutDistanceLabel(widget.unitSystem.distanceUnitLabel),
        child: TextField(
          controller: _distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: .done,
          onSubmitted: (_) => _submit(),
        ),
      ),
    ],
  );

  Future<void> _submit() => widget.isCardio ? _submitCardio() : _submitStrength();

  Future<void> _submitStrength() async {
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
    await _send(SetInput.strength(reps: reps, weightKg: widget.unitSystem.displayLoadToKilograms(displayLoad)));
  }

  Future<void> _submitCardio() async {
    final minutes = _minutesController.text.trim().isEmpty ? 0 : int.tryParse(_minutesController.text.trim());
    final seconds = _secondsController.text.trim().isEmpty ? 0 : int.tryParse(_secondsController.text.trim());
    if (minutes == null || seconds == null || minutes < 0 || seconds < 0) {
      setState(() => _errorMessage = context.l10n.workoutInvalidDurationMessage);
      return;
    }
    final totalSeconds = minutes * 60 + seconds;
    if (totalSeconds <= 0) {
      setState(() => _errorMessage = context.l10n.workoutInvalidDurationMessage);
      return;
    }
    final rawDistance = _distanceController.text.trim().replaceAll(',', '.');
    if (rawDistance.isEmpty) {
      await _send(SetInput.cardio(durationSeconds: totalSeconds));
      return;
    }
    final displayDistance = double.tryParse(rawDistance);
    if (displayDistance == null || displayDistance < 0) {
      setState(() => _errorMessage = context.l10n.workoutInvalidDistanceMessage);
      return;
    }
    await _send(SetInput.cardio(durationSeconds: totalSeconds, distanceMeters: widget.unitSystem.displayDistanceToMeters(displayDistance)));
  }

  Future<void> _send(SetInput input) async {
    final submittedResult = await widget.onSubmit(input: input);
    if (!mounted) {
      return;
    }
    submittedResult.when((error) => setState(() => _errorMessage = error.message), (_) => Navigator.of(context).pop());
  }
}
