import 'package:vitta/app/domain/diet/entities/nutrient.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String nutrientLabel(AppLocalizations l10n, Nutrient nutrient) => switch (nutrient) {
  Nutrient.vitaminA => l10n.nutrientVitaminA,
  Nutrient.vitaminC => l10n.nutrientVitaminC,
  Nutrient.vitaminD => l10n.nutrientVitaminD,
  Nutrient.vitaminE => l10n.nutrientVitaminE,
  Nutrient.vitaminK => l10n.nutrientVitaminK,
  Nutrient.vitaminB1 => l10n.nutrientVitaminB1,
  Nutrient.vitaminB2 => l10n.nutrientVitaminB2,
  Nutrient.vitaminB3 => l10n.nutrientVitaminB3,
  Nutrient.vitaminB6 => l10n.nutrientVitaminB6,
  Nutrient.folate => l10n.nutrientFolate,
  Nutrient.vitaminB12 => l10n.nutrientVitaminB12,
  Nutrient.calcium => l10n.nutrientCalcium,
  Nutrient.iron => l10n.nutrientIron,
  Nutrient.magnesium => l10n.nutrientMagnesium,
  Nutrient.potassium => l10n.nutrientPotassium,
  Nutrient.sodium => l10n.nutrientSodium,
  Nutrient.zinc => l10n.nutrientZinc,
};
