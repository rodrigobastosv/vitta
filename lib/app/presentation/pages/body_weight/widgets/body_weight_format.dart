import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

// Weight is stored in kilograms; this renders it in the reader's unit (kg/lb) with
// at most one decimal, then localizes the "{value} {unit}" join. Shared by the
// summary card, the log tiles and the history stats so they never drift.
String bodyWeightDisplay(AppLocalizations l10n, UnitSystem unitSystem, double weightKg) =>
    l10n.bodyWeightValue(_number(unitSystem.kilogramsToDisplayLoad(weightKg)), unitSystem.loadUnitLabel);

String _number(double value) {
  final rounded = value.round();
  return (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
}
