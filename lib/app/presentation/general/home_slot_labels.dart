import 'package:vitta/app/domain/home/entities/home_slot.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension HomeSlotLabel on HomeSlot {
  String label(AppLocalizations l10n) => switch (this) {
    .hero => l10n.homeSlotHero,
    .supporting => l10n.homeSlotSupporting,
    .tile => l10n.homeSlotTile,
    .hidden => l10n.homeSlotHidden,
  };
}
