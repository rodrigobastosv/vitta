import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/recipe.dart';

class RecipesState extends Equatable {
  const RecipesState({this.recipes = const []});

  final List<Recipe> recipes;

  RecipesState copyWith({List<Recipe>? recipes}) => RecipesState(recipes: recipes ?? this.recipes);

  @override
  List<Object?> get props => [recipes];
}
