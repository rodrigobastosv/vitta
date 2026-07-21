import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_search_field.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_details_dialog.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_tile.dart';
import 'package:vitta/app/presentation/pages/ingredient_picker/widgets/ingredient_quantity_sheet.dart';

class IngredientPickerPage extends StatelessWidget {
  const IngredientPickerPage({required this.unitSystem, super.key});

  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<FoodSearchCubit, FoodSearchState, FoodSearchPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case FoodSearchShowLoading():
            context.showLoading();
          case FoodSearchHideLoading():
            context.hideLoading();
          case FoodSearchError(:final message):
            context.showErrorToast(message: message);
          case FoodLogged():
            break;
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.dietPickIngredientTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(VTSpacing.m),
              child: VTSearchField(
                autofocus: true,
                hintText: l10n.dietSearchFieldLabel,
                onSubmitted: (query) => cubit.search(query: query),
              ),
            ),
            Expanded(
              child: switch (state) {
                FoodSearchState(results: null) => VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt),
                FoodSearchState(results: final results?) when results.isEmpty => VTEmptyState.noResults(message: l10n.dietSearchNoResults),
                FoodSearchState(results: final results?) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
                  itemBuilder: (context, index) {
                    final food = results[index];
                    final heroTag = 'ingredient-picker-$index';
                    return VTAppearEffect(
                      key: ValueKey('$index-${food.id ?? food.barcode ?? food.name}'),
                      index: index,
                      child: FoodSearchResultTile(
                        food: food,
                        heroTag: heroTag,
                        onTap: () => showFoodDetailsDialog(context: context, food: food, heroTag: heroTag),
                        onAdd: () => _pickQuantity(context, food),
                      ),
                    );
                  },
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickQuantity(BuildContext context, Food food) async {
    final ingredient = await showIngredientQuantitySheet(context: context, food: food, unitSystem: unitSystem);
    if (ingredient != null && context.mounted) {
      Navigator.of(context).pop(ingredient);
    }
  }
}
