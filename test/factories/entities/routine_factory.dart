import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

abstract class RoutineFactory {
  static Routine build({String id = 'routine-1', String name = 'Treino A', int position = 0, List<Exercise> exercises = const []}) =>
      Routine(id: id, name: name, position: position, exercises: exercises);

  /// An A/B/C cycle, the shape the rotation is actually used in.
  static List<Routine> buildCycle() => [
    build(id: 'routine-a'),
    build(id: 'routine-b', name: 'Treino B', position: 1),
    build(id: 'routine-c', name: 'Treino C', position: 2),
  ];
}
