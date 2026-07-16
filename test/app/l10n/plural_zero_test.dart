import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';
import 'package:vitta/l10n/arb/app_localizations_en.dart';
import 'package:vitta/l10n/arb/app_localizations_pt.dart';

void main() {
  final locales = <String, AppLocalizations>{'en': AppLocalizationsEn(), 'pt': AppLocalizationsPt()};

  final pluralsAtZero = <String, String Function(AppLocalizations)>{
    'workoutCompletedSummary': (l10n) => l10n.workoutCompletedSummary(0),
    'workoutRoutineExerciseCount': (l10n) => l10n.workoutRoutineExerciseCount(0),
    'dietCopyMealFoodCount': (l10n) => l10n.dietCopyMealFoodCount(0),
    'dietMealsCopiedToastMessage': (l10n) => l10n.dietMealsCopiedToastMessage(0),
  };

  group('no plural claims "1" when the count is zero', () {
    for (final MapEntry(key: name, value: atZero) in pluralsAtZero.entries) {
      test(name, () {
        for (final MapEntry(key: locale, value: l10n) in locales.entries) {
          expect(atZero(l10n), isNot(contains('1')), reason: '$name said "1" for zero in $locale - it is missing an explicit =0 case');
        }
      });
    }
  });

  group('the ordinary counts still read naturally', () {
    test('pt', () {
      final l10n = locales['pt']!;

      expect(l10n.workoutCompletedSummary(1), '1 série feita');
      expect(l10n.workoutCompletedSummary(3), '3 séries feitas');
      expect(l10n.workoutRoutineExerciseCount(1), '1 exercício');
      expect(l10n.workoutRoutineExerciseCount(4), '4 exercícios');
      expect(l10n.dietCopyMealFoodCount(1), '1 alimento');
      expect(l10n.dietCopyMealFoodCount(2), '2 alimentos');
      expect(l10n.dietMealsCopiedToastMessage(1), '1 refeição adicionada ao seu dia');
      expect(l10n.dietMealsCopiedToastMessage(2), '2 refeições adicionadas ao seu dia');
    });

    test('en', () {
      final l10n = locales['en']!;

      expect(l10n.workoutCompletedSummary(1), '1 set done');
      expect(l10n.workoutCompletedSummary(3), '3 sets done');
      expect(l10n.workoutRoutineExerciseCount(1), '1 exercise');
      expect(l10n.dietCopyMealFoodCount(1), '1 food');
      expect(l10n.dietMealsCopiedToastMessage(2), '2 meals added to your day');
    });
  });
}
