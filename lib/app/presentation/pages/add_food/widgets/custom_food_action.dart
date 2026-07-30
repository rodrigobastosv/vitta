import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/add_food_action_button.dart';

class CustomFoodAction extends StatelessWidget {
  const CustomFoodAction({required this.onFoodCreated, super.key});

  final void Function(Food food) onFoodCreated;

  @override
  Widget build(BuildContext context) => AddFoodActionButton(
    icon: Icons.edit_note_outlined,
    label: context.l10n.dietCustomFoodTitle,
    onTap: () async {
      final food = await context.pushRoute<Food>(.customFood);
      if (food != null) {
        onFoodCreated(food);
      }
    },
  );
}
