import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/add_food/widgets/food_result_tile.dart';

class FoodResultList extends StatelessWidget {
  const FoodResultList({
    required this.foods,
    required this.heroPrefix,
    required this.isFavorite,
    required this.onTapFood,
    required this.onAddFood,
    required this.onToggleFavorite,
    super.key,
  });

  final List<Food> foods;

  final String heroPrefix;
  final bool Function(Food food) isFavorite;
  final void Function(Food food, Object heroTag) onTapFood;
  final ValueChanged<Food> onAddFood;
  final ValueChanged<Food> onToggleFavorite;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
    itemCount: foods.length,
    separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
    itemBuilder: (context, index) {
      final food = foods[index];
      final heroTag = '$heroPrefix-$index';
      return VTAppearEffect(
        key: ValueKey('$heroPrefix-$index-${food.id ?? food.barcode ?? food.name}'),
        index: index,
        child: FoodResultTile(
          food: food,
          heroTag: heroTag,
          isFavorite: isFavorite(food),
          onTap: () => onTapFood(food, heroTag),
          onAdd: () => onAddFood(food),
          onToggleFavorite: () => onToggleFavorite(food),
        ),
      );
    },
  );
}
