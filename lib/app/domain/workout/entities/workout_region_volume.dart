import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/app/domain/workout/entities/workout.dart';

class WorkoutRegionVolume extends Equatable {
  const WorkoutRegionVolume({required this.volumeByRegion, this.setsByRegion = const {}});

  factory WorkoutRegionVolume.fromWorkouts(Iterable<Workout> workouts) {
    final volumeByRegion = <BodyRegion, double>{};
    final setsByRegion = <BodyRegion, int>{};
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final region = exercise.exercise.primaryMuscles.firstOrNull?.region;
        if (region == null) {
          continue;
        }
        volumeByRegion[region] = (volumeByRegion[region] ?? 0) + exercise.volumeKg;
        setsByRegion[region] = (setsByRegion[region] ?? 0) + exercise.sets.length;
      }
    }
    return WorkoutRegionVolume(volumeByRegion: volumeByRegion, setsByRegion: setsByRegion);
  }

  final Map<BodyRegion, double> volumeByRegion;
  final Map<BodyRegion, int> setsByRegion;

  double get totalVolumeKg => volumeByRegion.values.fold(0, (sum, volume) => sum + volume);

  bool get hasData => totalVolumeKg > 0;

  List<BodyRegion> get presentRegions => [
    for (final region in BodyRegion.values)
      if ((volumeByRegion[region] ?? 0) > 0) region,
  ]..sort((a, b) => volumeByRegion[b]!.compareTo(volumeByRegion[a]!));

  List<BodyRegion> get workedRegions {
    final worked = [
      for (final region in BodyRegion.values)
        if (setsOf(region) > 0) region,
    ];
    return worked..sort(_byWorkDescending);
  }

  int _byWorkDescending(BodyRegion a, BodyRegion b) {
    final bySets = setsOf(b).compareTo(setsOf(a));
    return bySets != 0 ? bySets : volumeOf(b).compareTo(volumeOf(a));
  }

  double volumeOf(BodyRegion region) => volumeByRegion[region] ?? 0;

  int setsOf(BodyRegion region) => setsByRegion[region] ?? 0;

  double shareOf(BodyRegion region) => hasData ? volumeOf(region) / totalVolumeKg : 0;

  double intensityOf(BodyRegion region) {
    final busiestRegionSets = setsByRegion.values.fold(0, (busiest, sets) => sets > busiest ? sets : busiest);
    return busiestRegionSets == 0 ? 0 : setsOf(region) / busiestRegionSets;
  }

  @override
  List<Object?> get props => [volumeByRegion, setsByRegion];
}
