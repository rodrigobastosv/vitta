import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/custom_food_action.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/meal_scan_action.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/meal_suggestion_action.dart';

/// The ways to add food that aren't searching for it, gathered into one labelled
/// bar instead of three unlabelled app-bar glyphs.
///
/// There is deliberately no disabled "Voice" placeholder: a button that does
/// nothing reads as broken rather than as forthcoming, and a fourth item drops
/// into this row with no rework when voice logging lands.
class AddFoodActionBar extends StatelessWidget {
  const AddFoodActionBar({required this.date, required this.onLogged, required this.onFoodCreated, super.key});

  final DateTime date;
  final VoidCallback onLogged;
  final void Function(Food food) onFoodCreated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
          child: Row(
            children: [
              MealScanAction(date: date, onLogged: onLogged),
              MealSuggestionAction(date: date, onLogged: onLogged),
              CustomFoodAction(onFoodCreated: onFoodCreated),
            ],
          ),
        ),
      ),
    );
  }
}
