import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

class FoodSourceBadge extends StatelessWidget {
  const FoodSourceBadge({required this.source, super.key});

  final FoodSource source;

  @override
  Widget build(BuildContext context) => switch (source) {
    FoodSource.recipe => VTBadge(label: context.l10n.dietRecipeBadge, color: VTColors.macroFiber),
    _ => const SizedBox.shrink(),
  };
}
