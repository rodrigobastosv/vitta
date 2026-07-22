import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/workout/entities/session_progress.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_energy.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';
import 'package:vitta/app/domain/workout/entities/workout_set.dart';
import 'package:vitta/app/domain/workout/entities/workout_volume.dart';

// The workout page already holds every one of these, so the summary takes them
// through the route rather than standing up a cubit to fetch them again - the
// DietDayPage reasoning. lastSetsByExercise is the *previous* session's sets,
// which is what makes the progression comparison free.
//
// It mixes in the totals the same way WorkoutState does, so the page reads figures
// off it rather than folding sets itself.
class WorkoutSummaryExtra with WorkoutVolume, WorkoutEnergy {
  const WorkoutSummaryExtra({
    required this.date,
    required this.workouts,
    required this.lastSetsByExercise,
    required this.latestBodyWeightKg,
    required this.unitSystem,
  });

  final DateTime date;
  final List<Workout> workouts;
  final Map<String, List<WorkoutSet>> lastSetsByExercise;
  final double? latestBodyWeightKg;
  final UnitSystem unitSystem;

  @override
  List<WorkoutExercise> get exercises => [for (final workout in workouts) ...workout.exercises];

  @override
  List<WorkoutSet> get sets => [for (final exercise in exercises) ...exercise.sets];

  bool get isBodyWeightKnown => latestBodyWeightKg != null;

  List<SessionProgress> get progress => [
    for (final exercise in exercises)
      SessionProgress(exercise: exercise, previousSets: lastSetsByExercise[exercise.exercise.id] ?? const []),
  ];
}
