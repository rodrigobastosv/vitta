import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';

class WorkoutRegionVolume extends Equatable {
  const WorkoutRegionVolume({required this.volumeByRegion});

  factory WorkoutRegionVolume.fromWorkouts(Iterable<Workout> workouts) {
    final volumeByRegion = <BodyRegion, double>{};
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final region = exercise.exercise.primaryMuscles.firstOrNull?.region;
        if (region == null) {
          continue;
        }
        volumeByRegion[region] = (volumeByRegion[region] ?? 0) + exercise.volumeKg;
      }
    }
    return WorkoutRegionVolume(volumeByRegion: volumeByRegion);
  }

  final Map<BodyRegion, double> volumeByRegion;

  double get totalVolumeKg => volumeByRegion.values.fold(0, (sum, volume) => sum + volume);

  bool get hasData => totalVolumeKg > 0;

  List<BodyRegion> get presentRegions => [
    for (final region in BodyRegion.values)
      if ((volumeByRegion[region] ?? 0) > 0) region,
  ]..sort((a, b) => volumeByRegion[b]!.compareTo(volumeByRegion[a]!));

  double volumeOf(BodyRegion region) => volumeByRegion[region] ?? 0;

  double shareOf(BodyRegion region) => hasData ? volumeOf(region) / totalVolumeKg : 0;

  @override
  List<Object?> get props => [volumeByRegion];
}
