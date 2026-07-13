import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String nutrientLabel(AppLocalizations l10n, Nutrient nutrient) => switch (nutrient) {
  .vitaminA => l10n.nutrientVitaminA,
  .vitaminC => l10n.nutrientVitaminC,
  .vitaminD => l10n.nutrientVitaminD,
  .vitaminE => l10n.nutrientVitaminE,
  .vitaminK => l10n.nutrientVitaminK,
  .vitaminB1 => l10n.nutrientVitaminB1,
  .vitaminB2 => l10n.nutrientVitaminB2,
  .vitaminB3 => l10n.nutrientVitaminB3,
  .vitaminB6 => l10n.nutrientVitaminB6,
  .folate => l10n.nutrientFolate,
  .vitaminB12 => l10n.nutrientVitaminB12,
  .calcium => l10n.nutrientCalcium,
  .iron => l10n.nutrientIron,
  .magnesium => l10n.nutrientMagnesium,
  .potassium => l10n.nutrientPotassium,
  .sodium => l10n.nutrientSodium,
  .zinc => l10n.nutrientZinc,
};
