import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

abstract class WorkoutSetsSummary {
  static String? format({required List<WorkoutSet> sets, required UnitSystem unitSystem, required AppLocalizations l10n}) {
    if (sets.isEmpty) {
      return null;
    }
    final reps = sets.first.reps;
    final weightKg = sets.first.weightKg;
    final uniform = sets.every((set) => set.reps == reps && set.weightKg == weightKg);
    if (uniform) {
      return '${l10n.workoutSetsSummaryUniform(sets.length, reps)} · ${_load(weightKg, unitSystem, l10n)}';
    }
    final topWeightKg = sets.map((set) => set.weightKg).reduce((a, b) => a > b ? a : b);
    return '${l10n.workoutSetsSummaryMixed(sets.length)} · ${_load(topWeightKg, unitSystem, l10n)}';
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
