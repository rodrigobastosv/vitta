import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String mealTypeLabel(AppLocalizations l10n, MealType mealType) => switch (mealType) {
  MealType.breakfast => l10n.mealTypeBreakfast,
  MealType.lunch => l10n.mealTypeLunch,
  MealType.dinner => l10n.mealTypeDinner,
  MealType.snack => l10n.mealTypeSnack,
};
