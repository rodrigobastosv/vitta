import 'package:flutter/material.dart';
import 'package:vitta/app/domain/body_profile/entities/activity_level.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension BiologicalSexLabel on BiologicalSex {
  String label(AppLocalizations l10n) => switch (this) {
    .male => l10n.bodyProfileSexMale,
    .female => l10n.bodyProfileSexFemale,
  };

  IconData get icon => switch (this) {
    .male => Icons.male_outlined,
    .female => Icons.female_outlined,
  };
}

extension ActivityLevelLabel on ActivityLevel {
  String label(AppLocalizations l10n) => switch (this) {
    .sedentary => l10n.bodyProfileActivitySedentary,
    .lightlyActive => l10n.bodyProfileActivityLightlyActive,
    .moderatelyActive => l10n.bodyProfileActivityModeratelyActive,
    .veryActive => l10n.bodyProfileActivityVeryActive,
    .extraActive => l10n.bodyProfileActivityExtraActive,
  };
}
