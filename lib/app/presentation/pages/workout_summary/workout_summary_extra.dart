import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/presentation/pages/workout/workout_state.dart';

class WorkoutSummaryExtra {
  const WorkoutSummaryExtra({required this.state, required this.unitSystem, this.celebrate = false});

  /// The day being summarised, handed over whole rather than re-fetched: the
  /// workout page already holds every set of the day, so the summary has a cubit
  /// of its own for exactly nothing (`DietDayPage`'s reasoning). It is
  /// `WorkoutState` rather than a bag of fields because that is the shape
  /// `WorkoutSummaryCard` already reads, and re-deriving it would be ceremony.
  final WorkoutState state;

  final UnitSystem unitSystem;

  /// Whether to burst confetti on arrival. True only when the workout was just
  /// finished - reopening a past day's summary from its CTA is a look back, not
  /// an achievement, and a celebration that fires every time it is opened goes
  /// stale (see the celebration scarcity rule).
  final bool celebrate;
}
