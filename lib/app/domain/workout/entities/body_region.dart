import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum BodyRegion {
  chest,
  back,
  shoulders,
  arms,
  core,
  legs;

  String getLabel(AppLocalizations l10n) => switch (this) {
    .chest => l10n.bodyRegionChest,
    .back => l10n.bodyRegionBack,
    .shoulders => l10n.bodyRegionShoulders,
    .arms => l10n.bodyRegionArms,
    .core => l10n.bodyRegionCore,
    .legs => l10n.bodyRegionLegs,
  };

  Color get color => switch (this) {
    .chest => VTColors.bodyRegionChest,
    .back => VTColors.bodyRegionBack,
    .shoulders => VTColors.bodyRegionShoulders,
    .arms => VTColors.bodyRegionArms,
    .core => VTColors.bodyRegionCore,
    .legs => VTColors.bodyRegionLegs,
  };

  IconData get icon => switch (this) {
    .chest => Icons.self_improvement_outlined,
    .back => Icons.airline_seat_flat_outlined,
    .shoulders => Icons.accessibility_new_outlined,
    .arms => Icons.sports_martial_arts_outlined,
    .core => Icons.center_focus_strong_outlined,
    .legs => Icons.directions_walk_outlined,
  };
}
