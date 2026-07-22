import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String formatWorkoutDuration(AppLocalizations l10n, int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return l10n.workoutDurationHm(hours, minutes);
  }
  if (minutes > 0 && seconds > 0) {
    return l10n.workoutDurationMs(minutes, seconds);
  }
  if (minutes > 0) {
    return l10n.workoutDurationM(minutes);
  }
  return l10n.workoutDurationS(seconds);
}

String formatWorkoutDistance(UnitSystem unitSystem, double meters) {
  final value = unitSystem.metersToDisplayDistance(meters);
  final rounded = value.round();
  final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
  return '$label ${unitSystem.distanceUnitLabel}';
}
