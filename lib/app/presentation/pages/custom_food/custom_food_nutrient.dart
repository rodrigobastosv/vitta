import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum CustomFoodNutrient {
  calories,
  protein,
  carbs,
  fat,
  fiber;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .calories => l10n.dietEnergyLabel,
    .protein => l10n.dietProteinLabel,
    .carbs => l10n.dietCarbsLabel,
    .fat => l10n.dietFatLabel,
    .fiber => l10n.dietFiberLabel,
  };

  String getUnitLabel(AppLocalizations l10n) => switch (this) {
    .calories => l10n.dietKcalUnit,
    _ => l10n.dietGramsUnit,
  };

  Color getColor(ColorScheme colorScheme) => switch (this) {
    .calories => colorScheme.primary,
    .protein => VTColors.macroProtein,
    .carbs => VTColors.macroCarbs,
    .fat => VTColors.macroFat,
    .fiber => VTColors.macroFiber,
  };

  double? valueOf(ScannedNutritionFacts facts) => switch (this) {
    .calories => facts.caloriesPer100g,
    .protein => facts.proteinPer100g,
    .carbs => facts.carbsPer100g,
    .fat => facts.fatPer100g,
    .fiber => facts.fiberPer100g,
  };
}
