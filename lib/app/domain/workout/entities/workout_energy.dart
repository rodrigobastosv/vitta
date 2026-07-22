import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/domain/workout/entities/workout_exercise.dart';

// Calories burned, estimated rather than measured (issue #168) - the app has no
// heart rate and no session clock, so this folds each exercise's own estimate the
// way WorkoutVolume folds tonnage. Mixed into whatever holds exercises, so one
// workout and a whole day total up through the same code.
mixin WorkoutEnergy {
  List<WorkoutExercise> get exercises;

  // bodyWeightKg is required but nullable, so a caller has to say whether it knows
  // the weight rather than silently passing a default it invented. Nothing has
  // been weighed yet falls back to "what a body looks like when nothing is known
  // about it", the same constant onboarding assumes - the figure stays coarse
  // either way, and the caller is expected to say which of the two it used rather
  // than let a default read as a weigh-in.
  double estimatedCalories({required double? bodyWeightKg}) {
    final weight = bodyWeightKg ?? BodyProfile.defaultWeightKg;
    return exercises.fold(0, (sum, exercise) => sum + exercise.estimatedCalories(bodyWeightKg: weight));
  }
}
