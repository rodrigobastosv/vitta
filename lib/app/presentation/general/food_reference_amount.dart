import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

/// How a food's nutrition is *stated*: per 100 g for something you weigh, per
/// 100 mL for something you pour — which is what a drink's own label says, and
/// what the search row has to say once the log sheet measures that food in mL.
///
/// The stored numbers are always per 100 g (grams are the domain's base unit,
/// exactly as they are for a logged quantity), so a liquid's are **scaled by its
/// density, never merely relabelled**: milk is 61 kcal per 100 g, and printing
/// that figure over "per 100 mL" would be wrong by the density — which is the
/// whole reason the column exists.
extension FoodReferenceAmount on Food {
  double per100Reference(double per100g) => switch (densityGPerMl) {
    final density? => per100g * density,
    null => per100g,
  };

  String caloriesPerReference(AppLocalizations l10n) => isMeasuredByVolume
      ? l10n.dietCaloriesPer100Ml(per100Reference(caloriesPer100g).round())
      : l10n.dietCaloriesPer100g(caloriesPer100g.round());

  String nutritionReferenceTitle(AppLocalizations l10n) => isMeasuredByVolume ? l10n.dietNutritionPer100MlTitle : l10n.dietNutritionPer100gTitle;
}
