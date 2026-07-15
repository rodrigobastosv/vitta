import 'package:vitta/l10n/arb/app_localizations.dart';

enum ExerciseCategory {
  strength,
  cardio,
  stretching,
  plyometrics,
  powerlifting,
  olympicWeightlifting,
  strongman;

  static ExerciseCategory fromWireValue(String value) => switch (value) {
    'strength' => ExerciseCategory.strength,
    'cardio' => ExerciseCategory.cardio,
    'stretching' => ExerciseCategory.stretching,
    'plyometrics' => ExerciseCategory.plyometrics,
    'powerlifting' => ExerciseCategory.powerlifting,
    'olympic_weightlifting' => ExerciseCategory.olympicWeightlifting,
    'strongman' => ExerciseCategory.strongman,
    _ => throw ArgumentError('Unknown exercise category: $value'),
  };

  String get wireValue => switch (this) {
    ExerciseCategory.olympicWeightlifting => 'olympic_weightlifting',
    _ => name,
  };

  String getLabel(AppLocalizations l10n) => switch (this) {
    .strength => l10n.exerciseCategoryStrength,
    .cardio => l10n.exerciseCategoryCardio,
    .stretching => l10n.exerciseCategoryStretching,
    .plyometrics => l10n.exerciseCategoryPlyometrics,
    .powerlifting => l10n.exerciseCategoryPowerlifting,
    .olympicWeightlifting => l10n.exerciseCategoryOlympicWeightlifting,
    .strongman => l10n.exerciseCategoryStrongman,
  };
}
