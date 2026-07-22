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

  bool get isCardio => this == .cardio;

  // The metabolic equivalent of the activity - how many times its resting rate a
  // body burns while doing it - which is what turns a session into calories
  // (kcal = MET x bodyweight kg x hours). Values are the Compendium of Physical
  // Activities' rounded figures for each family, paired with the case the way
  // DietModality pairs a case with its energy split.
  //
  // The catalog knows the family, never the intensity: it cannot tell a grinding
  // set from an easy one, or a sprint from a walk. So every value is the middle of
  // its range rather than the top - an estimate that reads low is a smaller lie
  // than one that flatters, and this number is shown as a reward.
  double get metValue => switch (this) {
    .strength => 5,
    .powerlifting => 6,
    .olympicWeightlifting => 6,
    .strongman => 8,
    .plyometrics => 8,
    .cardio => 7,
    .stretching => 2.5,
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
