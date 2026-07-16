import 'package:flutter_test/flutter_test.dart';

import '../../../../factories/entities/workout_set_factory.dart';

void main() {
  test('estimatedOneRepMax follows the Epley formula', () {
    expect(WorkoutSetFactory.build(reps: 8, weightKg: 100).estimatedOneRepMax, closeTo(100 * (1 + 8 / 30), 1e-9));
    expect(WorkoutSetFactory.build(reps: 1, weightKg: 80).estimatedOneRepMax, closeTo(80 * (1 + 1 / 30), 1e-9));
  });

  test('a bodyweight set has no estimated one-rep max', () {
    expect(WorkoutSetFactory.build(reps: 12, weightKg: 0).estimatedOneRepMax, 0);
  });
}
