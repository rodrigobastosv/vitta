import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/workout/entities/routine.dart';

/// The user's routines as a cycle, plus which one they did last.
///
/// The rotation rule is deliberately **position-based, not calendar-based**:
/// the next routine is simply the one after the last routine-backed workout,
/// wrapping at the end. It never looks at dates, which is the point - training
/// Monday/Wednesday/Friday, twice in one day, or after a three-week layoff all
/// advance the cycle identically, and missing a day never "skips" a routine the
/// way binding routines to weekdays would. Issue #94 weighed the weekday
/// alternative and dropped it for exactly that.
class RoutineCycle extends Equatable {
  const RoutineCycle({required this.routines, this.lastRoutineId});

  /// Ordered by `position` - the cycle order the user arranged, not insertion
  /// order.
  final List<Routine> routines;

  /// The routine of the most recent workout that came from one. Null when the
  /// user has never trained from a routine, or when the routine they last used
  /// has since been deleted (`workouts.routine_id` is `on delete set null`).
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

  /// The routine to suggest next. Null only when there are no routines at all.
  /// With no usable history it's the first of the cycle, which is also what a
  /// deleted-since last routine falls back to.
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
