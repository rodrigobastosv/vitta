import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

// Weight is stored in kilograms; this renders it in the reader's unit (kg/lb) with
// at most one decimal, then localizes the "{value} {unit}" join. Shared by the
// summary card, the log tiles and the history stats so they never drift.
String bodyWeightDisplay(AppLocalizations l10n, UnitSystem unitSystem, double weightKg) =>
    l10n.bodyWeightValue(_number(unitSystem.kilogramsToDisplayLoad(weightKg)), unitSystem.loadUnitLabel);

// A change over a window, rendered with an explicit +/− (a figure dash) so the
// direction reads without relying on colour - weight has no goal, so up/down
// carries no good/bad valence to colour it by. A flat change (< 0.05 kg) is
// unsigned. Shared by the summary pill and the trend stat so they never drift.
String bodyWeightSignedDisplay(AppLocalizations l10n, UnitSystem unitSystem, double deltaKg) {
  final magnitude = bodyWeightDisplay(l10n, unitSystem, deltaKg.abs());
  if (deltaKg.abs() < 0.05) {
    return magnitude;
  }
  return '${deltaKg < 0 ? '−' : '+'}$magnitude';
}

String _number(double value) {
  final rounded = value.round();
  return (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
}
