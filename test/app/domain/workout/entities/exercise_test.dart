import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

import '../../../../factories/entities/exercise_factory.dart';

void main() {
  group('Exercise.nameFor', () {
    test('returns the requested locale when the catalog has it', () {
      final exercise = ExerciseFactory.build(names: const {'en': 'Squat', 'pt': 'Agachamento'});

      expect(exercise.nameFor('pt'), 'Agachamento');
    });

    test('falls back to English when the locale is missing, so an untranslated row still renders', () {
      final exercise = ExerciseFactory.build(names: const {'en': 'Squat'});

      expect(exercise.nameFor('pt'), 'Squat');
    });
  });

  group('Exercise.fromMap', () {
    test('parses the locale-keyed blobs and drops muscles the app does not model', () {
      final exercise = Exercise.fromMap(const {
        'id': 'exercise-1',
        'names': {'en': 'Squat', 'pt': 'Agachamento'},
        'instructions': {
          'en': ['Stand up.', 'Sit down.'],
        },
        'category': 'strength',
        'level': 'beginner',
        'equipment': 'barbell',
        'primary_muscles': ['quadriceps', 'not_a_muscle'],
        'secondary_muscles': <String>[],
        'image_urls': ['https://example.com/1.jpg'],
        'times_logged': 3,
      });

      expect(exercise.nameFor('pt'), 'Agachamento');
      expect(exercise.instructionsFor('en'), ['Stand up.', 'Sit down.']);
      expect(exercise.primaryMuscles, [MuscleGroup.quadriceps]);
      expect(exercise.imageUrl, 'https://example.com/1.jpg');
      expect(exercise.timesLogged, 3);
    });

    test('tolerates an exercise with no translation, images, or micronutrient-style extras', () {
      final exercise = Exercise.fromMap(const {
        'id': 'exercise-1',
        'names': {'en': 'Squat'},
        'instructions': <String, dynamic>{},
        'category': 'strength',
        'level': 'beginner',
        'equipment': null,
        'primary_muscles': <String>[],
        'secondary_muscles': <String>[],
        'image_urls': <String>[],
      });

      expect(exercise.equipment, isNull);
      expect(exercise.imageUrl, isNull);
      expect(exercise.instructionsFor('pt'), isEmpty);
    });
  });
}
