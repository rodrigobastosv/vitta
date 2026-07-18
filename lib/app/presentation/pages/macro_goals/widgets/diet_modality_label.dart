import 'package:vitta/app/domain/diet/entities/diet_modality.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String dietModalityLabel(AppLocalizations l10n, DietModality modality) => switch (modality) {
  .balanced => l10n.dietModalityBalanced,
  .highProtein => l10n.dietModalityHighProtein,
  .lowFat => l10n.dietModalityLowFat,
  .lowCarb => l10n.dietModalityLowCarb,
  .keto => l10n.dietModalityKeto,
};
