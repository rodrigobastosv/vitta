import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/diet/entities/macro_nutrient.dart';
import 'package:vitta/app/domain/diet/entities/nutrient_verdict.dart';
import 'package:vitta/app/domain/diet/entities/nutrition_grade.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

// Labels, icons and accents for the score's three domain enums, kept out of the
// domain itself - the nutrientLabel pattern.
extension NutritionGradeLabel on NutritionGrade {
  String getLabel(AppLocalizations l10n) => switch (this) {
    .poor => l10n.nutritionGradePoor,
    .fair => l10n.nutritionGradeFair,
    .good => l10n.nutritionGradeGood,
    .excellent => l10n.nutritionGradeExcellent,
  };

  Color get color => switch (this) {
    .poor => VTColors.error,
    .fair => VTColors.warningStrong,
    .good => VTColors.success,
    .excellent => VTColors.green,
  };
}

extension NutrientVerdictLabel on NutrientVerdict {
  String getLabel(AppLocalizations l10n) => switch (this) {
    .low => l10n.nutrientVerdictLow,
    .onTrack => l10n.nutrientVerdictOnTrack,
    .high => l10n.nutrientVerdictHigh,
  };

  // Landing in the band is the good outcome and reads green; either miss reads
  // warningStrong, which unlike plain warning is legible as ink.
  Color get color => switch (this) {
    .onTrack => VTColors.success,
    .low || .high => VTColors.warningStrong,
  };
}

extension MacroNutrientLabel on MacroNutrient {
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

  Color get color => switch (this) {
    .calories => VTColors.coral,
    .protein => VTColors.macroProtein,
    .carbs => VTColors.macroCarbs,
    .fat => VTColors.macroFat,
    .fiber => VTColors.macroFiber,
  };

  IconData get icon => switch (this) {
    .calories => Icons.bolt_rounded,
    .protein => Icons.egg_alt_outlined,
    .carbs => Icons.bakery_dining_outlined,
    .fat => Icons.water_drop_outlined,
    .fiber => Icons.grass_outlined,
  };
}
