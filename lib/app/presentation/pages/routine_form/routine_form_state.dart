import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';
import 'package:vitta/app/domain/workout/entities/routine_draft.dart';

class RoutineFormState extends Equatable {
  const RoutineFormState({required this.draft, this.routine});

  final RoutineDraft draft;

  final Routine? routine;

  bool get isEditing => routine != null;

  RoutineFormState copyWith({RoutineDraft? draft}) => RoutineFormState(draft: draft ?? this.draft, routine: routine);

  @override
  List<Object?> get props => [draft, routine];
}
