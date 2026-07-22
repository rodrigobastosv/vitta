import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

abstract class WorkoutSetsSummary {
  static String? format({required List<WorkoutSet> sets, required UnitSystem unitSystem, required AppLocalizations l10n}) {
    if (sets.isEmpty) {
      return null;
    }
    if (sets.first.isCardio) {
      return _cardio(sets, unitSystem, l10n);
    }
    final reps = sets.first.reps;
    final weightKg = sets.first.weightKg;
    final uniform = sets.every((set) => set.reps == reps && set.weightKg == weightKg);
    if (uniform) {
      return '${l10n.workoutSetsSummaryUniform(sets.length, reps ?? 0)} · ${_load(weightKg, unitSystem, l10n)}';
    }
    final topWeightKg = sets.map((set) => set.weightKg).reduce((a, b) => a > b ? a : b);
    return '${l10n.workoutSetsSummaryMixed(sets.length)} · ${_load(topWeightKg, unitSystem, l10n)}';
  }

  static String _cardio(List<WorkoutSet> sets, UnitSystem unitSystem, AppLocalizations l10n) {
    final totalSeconds = sets.fold(0, (sum, set) => sum + (set.durationSeconds ?? 0));
    final totalMeters = sets.fold<double>(0, (sum, set) => sum + (set.distanceMeters ?? 0));
    final minutes = totalSeconds ~/ 60;
    final durationLabel = minutes > 0 ? l10n.workoutDurationM(minutes) : l10n.workoutDurationS(totalSeconds);
    return totalMeters > 0 ? '$durationLabel · ${_distance(totalMeters, unitSystem)}' : durationLabel;
  }

  static String _distance(double meters, UnitSystem unitSystem) {
    final value = unitSystem.metersToDisplayDistance(meters);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.distanceUnitLabel}';
  }

  static String _load(double weightKg, UnitSystem unitSystem, AppLocalizations l10n) {
    if (weightKg == 0) {
      return l10n.workoutBodyweightLabel;
    }
    final value = unitSystem.kilogramsToDisplayLoad(weightKg);
    final rounded = value.round();
    final label = (value - rounded).abs() < 0.05 ? '$rounded' : value.toStringAsFixed(1);
    return '$label ${unitSystem.loadUnitLabel}';
  }
}
