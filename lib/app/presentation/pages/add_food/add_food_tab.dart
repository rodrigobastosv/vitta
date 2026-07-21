import 'package:vitta/l10n/arb/app_localizations.dart';

enum AddFoodTab {
  search,
  recent,
  favorites;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .search => l10n.dietSearchTabLabel,
    .recent => l10n.dietRecentTabLabel,
    .favorites => l10n.dietFavoritesTitle,
  };
}
