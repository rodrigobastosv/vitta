import 'package:flutter/material.dart';
import 'package:vitta/app/domain/diet/entities/diet_modality.dart';

// A glyph that reads as the modality at a glance - balance scales for balanced, an
// egg for the protein-forward split, bread for the carb it limits, a bolt for keto's
// energy. Presentation-only, like dietModalityLabel, so the domain enum stays
// Flutter-free.
IconData dietModalityIcon(DietModality modality) => switch (modality) {
  .balanced => Icons.balance,
  .highProtein => Icons.egg_alt,
  .lowFat => Icons.spa,
  .lowCarb => Icons.bakery_dining,
  .keto => Icons.bolt,
};
