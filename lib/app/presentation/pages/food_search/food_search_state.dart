import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_tab.dart';

class FoodSearchState extends Equatable {
  const FoodSearchState({
    this.results,
    this.favorites = const [],
    this.recentSearches = const [],
    this.recentFoods = const [],
    this.query = '',
    this.tab = FoodSearchTab.search,
  });

  final List<Food>? results;

  final List<Food> favorites;

  final List<String> recentSearches;

  final List<FoodLogEntry> recentFoods;

  final String query;

  final FoodSearchTab tab;

  Set<String> get favoriteFoodIds => {for (final food in favorites) ?food.id};

  bool isFavorite(Food food) => food.id == null ? favorites.contains(food) : favoriteFoodIds.contains(food.id);

  FoodSearchState copyWith({
    List<Food>? results,
    List<Food>? favorites,
    List<String>? recentSearches,
    List<FoodLogEntry>? recentFoods,
    String? query,
    FoodSearchTab? tab,
  }) => FoodSearchState(
    results: results ?? this.results,
    favorites: favorites ?? this.favorites,
    recentSearches: recentSearches ?? this.recentSearches,
    recentFoods: recentFoods ?? this.recentFoods,
    query: query ?? this.query,
    tab: tab ?? this.tab,
  );

  @override
  List<Object?> get props => [results, favorites, recentSearches, recentFoods, query, tab];
}
