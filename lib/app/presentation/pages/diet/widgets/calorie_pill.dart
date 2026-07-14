import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';

class CaloriePill extends StatelessWidget {
  const CaloriePill({required this.calories, required this.color, super.key});

  final int calories;
  final Color color;

  @override
  Widget build(BuildContext context) => VTBadge(label: context.l10n.dietMealCalories(calories), color: color);
}
