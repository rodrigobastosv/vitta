import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_search_field.dart';
import 'package:vitta/app/design_system/components/general/vt_segmented_tabs.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_presentation_event.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_state.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_tab.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_details_dialog.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/food_search_result_list.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/log_food_sheet.dart';
import 'package:vitta/app/presentation/pages/food_search/widgets/recent_searches_list.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

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
            context.showToast(title: foodName, message: l10n.dietFoodLoggedToast(mealType.getLabel(l10n)));
          case FoodSearchError(:final message):
            context.showErrorToast(message: message);
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
                final food = await context.pushRoute<Food>(.customFood);
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
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
              child: VTSegmentedTabs<FoodSearchTab>(
                selected: state.tab,
                onSelected: cubit.changeTab,
                tabs: [
                  for (final tab in FoodSearchTab.values) VTSegmentedTab(value: tab, label: tab.getLabel(l10n), icon: tab.icon),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (state.tab) {
                  FoodSearchTab.search => _buildSearchTab(context, cubit, state, l10n),
                  FoodSearchTab.favorites => _buildFavoritesTab(context, cubit, state, l10n),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(BuildContext context, FoodSearchCubit cubit, FoodSearchState state, AppLocalizations l10n) => Column(
    key: const ValueKey(FoodSearchTab.search),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, VTSpacing.m),
        child: VTSearchField(
          autofocus: true,
          text: state.query,
          hintText: l10n.dietSearchFieldLabel,
          onSubmitted: (query) => cubit.search(query: query),
        ),
      ),
      Expanded(
        child: switch (state.results) {
          null when state.recentSearches.isEmpty => VTEmptyState(icon: Icons.search, message: l10n.dietSearchPrompt),
          null => RecentSearchesList(
            queries: state.recentSearches,
            onSelect: (query) => cubit.search(query: query),
            onRemove: (query) => cubit.removeRecentSearch(query: query),
            onClear: cubit.clearRecentSearches,
          ),
          final results when results.isEmpty => VTEmptyState(message: l10n.dietSearchNoResults),
          final results => _buildList(context: context, cubit: cubit, state: state, foods: results, heroPrefix: 'food-search'),
        },
      ),
    ],
  );

  Widget _buildFavoritesTab(BuildContext context, FoodSearchCubit cubit, FoodSearchState state, AppLocalizations l10n) => Padding(
    key: const ValueKey(FoodSearchTab.favorites),
    padding: const EdgeInsets.only(top: VTSpacing.m),
    child: state.favorites.isEmpty
        ? VTEmptyState(icon: Icons.favorite_border, title: l10n.dietFavoritesEmptyTitle, message: l10n.dietFavoritesEmptyMessage)
        : _buildList(context: context, cubit: cubit, state: state, foods: state.favorites, heroPrefix: 'food-favorite'),
  );

  Widget _buildList({
    required BuildContext context,
    required FoodSearchCubit cubit,
    required FoodSearchState state,
    required List<Food> foods,
    required String heroPrefix,
  }) => FoodSearchResultList(
    foods: foods,
    heroPrefix: heroPrefix,
    isFavorite: state.isFavorite,
    onTapFood: (food, heroTag) => showFoodDetailsDialog(context: context, food: food, heroTag: heroTag),
    onAddFood: (food) => showLogFoodSheet(context: context, food: food, loggedDate: loggedDate, initialMealType: initialMealType),
    onToggleFavorite: (food) => cubit.toggleFavorite(food: food),
  );
}
