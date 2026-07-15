import 'package:vitta/app/domain/workout/entities/equipment.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/exercise_category.dart';
import 'package:vitta/app/domain/workout/entities/exercise_level.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

abstract class ExerciseFactory {
  static Exercise build({
    String id = 'exercise-1',
    Map<String, String> names = const {'en': 'Incline Dumbbell Press', 'pt': 'Supino inclinado com halteres'},
    Map<String, List<String>> instructions = const {},
    ExerciseCategory category = ExerciseCategory.strength,
    ExerciseLevel level = ExerciseLevel.intermediate,
    Equipment? equipment = Equipment.dumbbell,
    List<MuscleGroup> primaryMuscles = const [MuscleGroup.chest],
    List<MuscleGroup> secondaryMuscles = const [MuscleGroup.triceps],
    List<String> imageUrls = const [],
    int timesLogged = 0,
  }) => Exercise(
    id: id,
    names: names,
    instructions: instructions,
    category: category,
    level: level,
    equipment: equipment,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    imageUrls: imageUrls,
    timesLogged: timesLogged,
  );
}
