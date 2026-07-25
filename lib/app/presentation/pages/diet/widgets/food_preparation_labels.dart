import 'package:vitta/app/domain/diet/entities/food_preparation.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension FoodPreparationLabel on FoodPreparation {
  String label(AppLocalizations l10n) => switch (this) {
    .raw => l10n.dietPreparationRaw,
    .cooked => l10n.dietPreparationCooked,
  };
}
