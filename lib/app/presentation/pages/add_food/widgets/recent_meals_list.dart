import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/recent_meal.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/recent_meal_tile.dart';

class RecentMealsList extends StatelessWidget {
  const RecentMealsList({required this.title, required this.meals, required this.onLogAgain, super.key});

  final String title;
  final List<RecentMeal> meals;
  final void Function(RecentMeal meal) onLogAgain;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
        child: Text(title, style: VTTextStyles.overline(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
      ),
      const VTGap.s(),
      for (final (index, meal) in meals.indexed) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
          child: VTAppearEffect(index: index, child: RecentMealTile(meal: meal, onLogAgain: () => onLogAgain(meal))),
        ),
        const VTGap.s(),
      ],
    ],
  );
}
