import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutineCycle extends Equatable {
  const RoutineCycle({required this.routines, this.lastRoutineId});

  final List<Routine> routines;

  final String? lastRoutineId;

  Routine? get lastRoutine {
    final id = lastRoutineId;
    if (id == null) {
      return null;
    }
    for (final routine in routines) {
      if (routine.id == id) {
        return routine;
      }
    }
    return null;
  }

  Routine? get next {
    if (routines.isEmpty) {
      return null;
    }
    final last = lastRoutine;
    if (last == null) {
      return routines.first;
    }
    return routines[(routines.indexOf(last) + 1) % routines.length];
  }

  @override
  List<Object?> get props => [routines, lastRoutineId];
}
