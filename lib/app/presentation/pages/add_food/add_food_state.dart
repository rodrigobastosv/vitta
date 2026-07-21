import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';
import 'package:vitta/app/presentation/pages/add_food/add_food_tab.dart';

class AddFoodState extends Equatable {
  const AddFoodState({
    this.results,
    this.favorites = const [],
    this.recentSearches = const [],
    this.recentFoods = const [],
    this.query = '',
    this.tab = AddFoodTab.search,
  });

  final List<Food>? results;

  final List<Food> favorites;

  final List<String> recentSearches;

  final List<FoodLogEntry> recentFoods;

  final String query;

  final AddFoodTab tab;

  Set<String> get favoriteFoodIds => {for (final food in favorites) ?food.id};

  bool isFavorite(Food food) => food.id == null ? favorites.contains(food) : favoriteFoodIds.contains(food.id);

  AddFoodState copyWith({
    List<Food>? results,
    List<Food>? favorites,
    List<String>? recentSearches,
    List<FoodLogEntry>? recentFoods,
    String? query,
    AddFoodTab? tab,
  }) => AddFoodState(
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
