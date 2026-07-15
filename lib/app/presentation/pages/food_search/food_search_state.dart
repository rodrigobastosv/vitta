import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_tab.dart';

class FoodSearchState extends Equatable {
  const FoodSearchState({this.results, this.favorites = const [], this.tab = FoodSearchTab.search});

  /// `null` means no search has been performed yet (idle); an empty list means
  /// a search ran and found nothing.
  final List<Food>? results;

  /// The user's favourite foods, newest first. Backs the favourites tab and is
  /// the source of truth for whether any food's heart is filled.
  final List<Food> favorites;

  final FoodSearchTab tab;

  Set<String> get favoriteFoodIds => {
    for (final food in favorites)
      if (food.id != null) food.id!,
  };

  /// A food straight out of Open Food Facts has no id until favouriting saves
  /// it, and an optimistic toggle shows it as a favourite before that id
  /// exists — so an id-less food is matched by value instead.
  bool isFavorite(Food food) => food.id == null ? favorites.contains(food) : favoriteFoodIds.contains(food.id);

  FoodSearchState copyWith({List<Food>? results, List<Food>? favorites, FoodSearchTab? tab}) =>
      FoodSearchState(results: results ?? this.results, favorites: favorites ?? this.favorites, tab: tab ?? this.tab);

  @override
  List<Object?> get props => [results, favorites, tab];
}
