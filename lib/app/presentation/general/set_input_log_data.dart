import 'package:vitta/app/domain/workout/entities/set_input.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';

// Shared by the two cubits that log a set - the day list and the exercise
// workspace - so the same action can never reach analytics under two different
// payload shapes depending on which screen the user logged it from.
Map<String, Object?> setInputLogData(SetInput input) => input.kind == SetKind.cardio
    ? {'duration_seconds': input.durationSeconds, 'distance_meters': input.distanceMeters}
    : {'reps': input.reps, 'weight_kg': input.weightKg};
