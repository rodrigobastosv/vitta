import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/custom_food_sheet.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_tile.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/log_food_sheet.dart';

class FoodSearchPage extends StatelessWidget {
  const FoodSearchPage({required this.loggedDate, this.initialMealType, super.key});

  final DateTime loggedDate;
  final MealType? initialMealType;

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
          case FoodLogged(:final foodName, :final mealType):
            context.showToast(title: foodName, message: l10n.dietFoodLoggedToast(mealType.getLabel(l10n)), accentColor: mealType.color);
          case FoodSearchError(:final message):
            context.showErrorDialog(message: message);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.dietFoodSearchTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.dietCustomFoodTitle,
              onPressed: () async {
                final food = await showCustomFoodSheet(context: context);
                if (food != null && context.mounted) {
                  await showLogFoodSheet(context: context, food: food, loggedDate: loggedDate, initialMealType: initialMealType);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(VTSpacing.m),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.dietSearchFieldLabel, prefixIcon: const Icon(Icons.search)),
                onSubmitted: (query) => cubit.search(query: query),
              ),
            ),
            Expanded(
              child: switch (state) {
                FoodSearchState(results: null) => VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt),
                FoodSearchState(results: final results?) when results.isEmpty => VTEmptyState(message: l10n.dietSearchNoResults),
                FoodSearchState(results: final results?) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
                  itemBuilder: (context, index) {
                    final food = results[index];
                    return FoodSearchResultTile(
                      food: food,
                      onTap: () => showLogFoodSheet(context: context, food: food, loggedDate: loggedDate, initialMealType: initialMealType),
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
}
