import 'package:vitta/app/domain/workout/entities/routine.dart';

class RoutineFormExtra {
  const RoutineFormExtra({this.routine});

  /// Null when creating. The form is one page doing both, so this is what
  /// switches it - the same shape RecipeFormExtra uses.
  final Routine? routine;
}
