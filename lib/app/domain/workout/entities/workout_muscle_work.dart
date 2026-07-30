import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

class WorkoutMuscleWork extends Equatable {
  const WorkoutMuscleWork({required this.activeSecondsByMuscle});

  factory WorkoutMuscleWork.fromExercises(Iterable<WorkoutExercise> exercises) {
    final activeSecondsByMuscle = <MuscleGroup, double>{};
    for (final exercise in exercises) {
      final activeSeconds = exercise.estimatedActiveSeconds.toDouble();
      if (activeSeconds == 0) {
        continue;
      }
      for (final muscle in exercise.exercise.primaryMuscles) {
        activeSecondsByMuscle[muscle] = (activeSecondsByMuscle[muscle] ?? 0) + activeSeconds;
      }
      for (final muscle in exercise.exercise.secondaryMuscles) {
        activeSecondsByMuscle[muscle] = (activeSecondsByMuscle[muscle] ?? 0) + activeSeconds * secondaryMuscleShare;
      }
    }
    return WorkoutMuscleWork(activeSecondsByMuscle: activeSecondsByMuscle);
  }

  factory WorkoutMuscleWork.fromWorkouts(Iterable<Workout> workouts) =>
      WorkoutMuscleWork.fromExercises(workouts.expand((workout) => workout.exercises));

  static const double secondaryMuscleShare = 0.5;

  final Map<MuscleGroup, double> activeSecondsByMuscle;

  bool get hasData => activeSecondsByMuscle.values.any((activeSeconds) => activeSeconds > 0);

  List<MuscleGroup> get workedMuscles {
    final worked = [
      for (final muscle in MuscleGroup.values)
        if (activeSecondsOf(muscle) > 0) muscle,
    ];
    return worked..sort(_byWorkDescending);
  }

  List<BodyRegion> get workedRegions {
    final activeSecondsByRegion = <BodyRegion, double>{};
    for (final muscle in workedMuscles) {
      activeSecondsByRegion[muscle.region] = (activeSecondsByRegion[muscle.region] ?? 0) + activeSecondsOf(muscle);
    }
    final worked = [
      for (final region in BodyRegion.values)
        if ((activeSecondsByRegion[region] ?? 0) > 0) region,
    ];
    return worked
      ..sort((a, b) {
        final byWork = activeSecondsByRegion[b]!.compareTo(activeSecondsByRegion[a]!);
        return byWork != 0 ? byWork : a.index.compareTo(b.index);
      });
  }

  double activeSecondsOf(MuscleGroup muscle) => activeSecondsByMuscle[muscle] ?? 0;

  double intensityOf(MuscleGroup muscle) {
    final busiestMuscleSeconds = activeSecondsByMuscle.values.fold<double>(
      0,
      (busiest, activeSeconds) => activeSeconds > busiest ? activeSeconds : busiest,
    );
    return busiestMuscleSeconds == 0 ? 0 : activeSecondsOf(muscle) / busiestMuscleSeconds;
  }

  int _byWorkDescending(MuscleGroup a, MuscleGroup b) {
    final byWork = activeSecondsOf(b).compareTo(activeSecondsOf(a));
    return byWork != 0 ? byWork : a.index.compareTo(b.index);
  }

  @override
  List<Object?> get props => [activeSecondsByMuscle];
}
