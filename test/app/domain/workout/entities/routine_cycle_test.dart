import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/routine_cycle.dart';

import '../../../../factories/entities/routine_factory.dart';

void main() {
  group('RoutineCycle.next', () {
    test('suggests the first routine when nothing has been trained yet', () {
      final cycle = RoutineCycle(routines: RoutineFactory.buildCycle());

      expect(cycle.next?.id, 'routine-a');
    });

    test('advances to the routine after the last one', () {
      final cycle = RoutineCycle(routines: RoutineFactory.buildCycle(), lastRoutineId: 'routine-a');

      expect(cycle.next?.id, 'routine-b');
    });

    test('wraps from the last routine back to the first', () {
      final cycle = RoutineCycle(routines: RoutineFactory.buildCycle(), lastRoutineId: 'routine-c');

      expect(cycle.next?.id, 'routine-a');
    });

    test('falls back to the first routine when the last one was deleted since', () {
      final cycle = RoutineCycle(routines: RoutineFactory.buildCycle(), lastRoutineId: 'routine-deleted');

      expect(cycle.next?.id, 'routine-a');
    });

    test('has nothing to suggest with no routines', () {
      const cycle = RoutineCycle(routines: []);

      expect(cycle.next, isNull);
    });

    test('a single routine always suggests itself rather than running out', () {
      final cycle = RoutineCycle(
        routines: [RoutineFactory.build(id: 'only')],
        lastRoutineId: 'only',
      );

      expect(cycle.next?.id, 'only');
    });

    test('advances by cycle position, never by date - the whole point of the rule', () {
      final routines = RoutineFactory.buildCycle();
      // Same last routine, regardless of whether it was trained today or a
      // month ago: the cycle carries no date at all.
      final cycle = RoutineCycle(routines: routines, lastRoutineId: 'routine-b');

      expect(cycle.next?.id, 'routine-c');
    });
  });
}
