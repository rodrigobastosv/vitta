import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutineDraft extends Equatable {
  const RoutineDraft({this.name = '', this.exercises = const []});

  factory RoutineDraft.fromRoutine(Routine routine) => RoutineDraft(name: routine.name, exercises: routine.exercises);

  final String name;
  final List<Exercise> exercises;

  bool get isComplete => name.trim().isNotEmpty && exercises.isNotEmpty;

  RoutineDraft copyWith({String? name, List<Exercise>? exercises}) => RoutineDraft(name: name ?? this.name, exercises: exercises ?? this.exercises);

  @override
  List<Object?> get props => [name, exercises];
}
