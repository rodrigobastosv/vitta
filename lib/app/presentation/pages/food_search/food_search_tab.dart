import 'package:flutter/material.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum FoodSearchTab {
  search,
  favorites;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .search => l10n.dietSearchTabLabel,
    .favorites => l10n.dietFavoritesTitle,
  };

  IconData get icon => switch (this) {
    .search => Icons.search,
    .favorites => Icons.favorite,
  };
}
