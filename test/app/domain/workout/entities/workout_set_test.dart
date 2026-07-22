import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/set_kind.dart';

import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('estimatedOneRepMax follows the Epley formula', () {
    expect(WorkoutSetFactory.build(reps: 8, weightKg: 100).estimatedOneRepMax, closeTo(100 * (1 + 8 / 30), 1e-9));
    expect(WorkoutSetFactory.build(reps: 1, weightKg: 80).estimatedOneRepMax, closeTo(80 * (1 + 1 / 30), 1e-9));
  });

  test('a bodyweight set has no estimated one-rep max', () {
    expect(WorkoutSetFactory.build(reps: 12, weightKg: 0).estimatedOneRepMax, 0);
  });

  test('a strength set is not cardio and contributes its tonnage', () {
    final set = WorkoutSetFactory.build();
    expect(set.kind, SetKind.strength);
    expect(set.isCardio, isFalse);
    expect(set.volumeKg, 400);
  });

  test('a cardio set carries duration and distance, no reps, and zero volume', () {
    final set = WorkoutSetFactory.cardio();
    expect(set.kind, SetKind.cardio);
    expect(set.isCardio, isTrue);
    expect(set.reps, isNull);
    expect(set.volumeKg, 0);
    expect(set.isBodyweight, isFalse);
  });
}
