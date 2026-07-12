import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_error_state.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/custom_food_sheet.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_tile.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/log_food_sheet.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class FoodSearchPage extends StatelessWidget {
  const FoodSearchPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<FoodSearchCubit, FoodSearchState, FoodSearchPresentationEvent>(
    builder: (context, cubit, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.dietFoodSearchTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.dietCustomFoodTitle,
              onPressed: () async {
                final food = await showCustomFoodSheet(context: context);
                if (food != null && context.mounted) {
                  await showLogFoodSheet(context: context, food: food);
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
                FoodSearchIdle() => VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt),
                FoodSearchError(:final message) => VTErrorState(message: message),
                FoodSearchLoaded(:final results) when results.isEmpty => VTEmptyState(message: l10n.dietSearchNoResults),
                FoodSearchLoaded(:final results) => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const SizedBox(height: VTSpacing.s),
                  itemBuilder: (context, index) {
                    final food = results[index];
                    return FoodSearchResultTile(food: food, onTap: () => showLogFoodSheet(context: context, food: food));
                  },
                ),
              },
            ),
          ],
        ),
      );
    },
  );
}
