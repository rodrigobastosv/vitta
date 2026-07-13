import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  static MealType fromWireValue(String value) => MealType.values.firstWhere((mealType) => mealType.wireValue == value);

  String get wireValue => name;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .breakfast => l10n.mealTypeBreakfast,
    .lunch => l10n.mealTypeLunch,
    .dinner => l10n.mealTypeDinner,
    .snack => l10n.mealTypeSnack,
  };

  IconData get icon => switch (this) {
    .breakfast => Icons.wb_sunny_outlined,
    .lunch => Icons.lunch_dining_outlined,
    .dinner => Icons.dinner_dining_outlined,
    .snack => Icons.bakery_dining_outlined,
  };

  Color get color => switch (this) {
    .breakfast => VTColors.macroProtein,
    .lunch => VTColors.green,
    .dinner => VTColors.macroFat,
    .snack => VTColors.macroCarbs,
  };
}
