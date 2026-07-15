import 'package:vitta/l10n/arb/app_localizations.dart';

enum ExerciseLevel {
  beginner,
  intermediate,
  expert;

  static ExerciseLevel fromWireValue(String value) => ExerciseLevel.values.firstWhere((level) => level.wireValue == value);

  String get wireValue => name;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .beginner => l10n.exerciseLevelBeginner,
    .intermediate => l10n.exerciseLevelIntermediate,
    .expert => l10n.exerciseLevelExpert,
  };
}
