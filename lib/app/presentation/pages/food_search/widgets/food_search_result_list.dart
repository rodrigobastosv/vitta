import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_tile.dart';

class FoodSearchResultList extends StatelessWidget {
  const FoodSearchResultList({
    required this.foods,
    required this.heroPrefix,
    required this.isFavorite,
    required this.onTapFood,
    required this.onAddFood,
    required this.onToggleFavorite,
    super.key,
  });

  final List<Food> foods;

  /// Keeps the Hero tags of the favourites list and the results list from
  /// colliding when both have rendered in the same session.
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
        delay: Duration(milliseconds: index.clamp(0, 10) * 50),
        child: FoodSearchResultTile(
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
