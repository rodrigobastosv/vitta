import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';
import 'package:vitta/l10n/arb/app_localizations_en.dart';
import 'package:vitta/l10n/arb/app_localizations_pt.dart';

/// Portuguese classifies zero as the `one` plural category (`_pt_rule`:
/// `if (_i == 0 || _i == 1) return ONE`). So a message declaring only `=1` and
/// `other` renders "1 série feita" for zero — the count is simply wrong, and
/// only in pt: English maps 0 to `other` and reads fine.
///
/// Every plural in the app therefore needs an explicit `=0` case. These tests
/// exist so that rule can't quietly rot.
void main() {
  final locales = <String, AppLocalizations>{'en': AppLocalizationsEn(), 'pt': AppLocalizationsPt()};

  group('workoutCompletedSummary', () {
    test('does not claim one set when there are none', () {
      for (final MapEntry(key: locale, value: l10n) in locales.entries) {
        expect(l10n.workoutCompletedSummary(0), isNot(contains('1')), reason: 'locale $locale said "1" for zero sets');
      }
    });

    test('still reads naturally for one and many', () {
      expect(locales['pt']!.workoutCompletedSummary(1), '1 série feita');
      expect(locales['pt']!.workoutCompletedSummary(3), '3 séries feitas');
      expect(locales['en']!.workoutCompletedSummary(1), '1 set done');
      expect(locales['en']!.workoutCompletedSummary(3), '3 sets done');
    });
  });

  group('workoutRoutineExerciseCount', () {
    test('does not claim one exercise when there are none', () {
      for (final MapEntry(key: locale, value: l10n) in locales.entries) {
        expect(
          l10n.workoutRoutineExerciseCount(0),
          isNot(contains('1')),
          reason: 'locale $locale said "1" for zero exercises',
        );
      }
    });

    test('still reads naturally for one and many', () {
      expect(locales['pt']!.workoutRoutineExerciseCount(1), '1 exercício');
      expect(locales['pt']!.workoutRoutineExerciseCount(4), '4 exercícios');
    });
  });
}
