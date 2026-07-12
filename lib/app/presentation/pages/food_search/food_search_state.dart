import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';

class FoodSearchState extends Equatable {
  const FoodSearchState({this.results});

  /// `null` means no search has been performed yet (idle); an empty list means
  /// a search ran and found nothing.
  final List<Food>? results;

  FoodSearchState copyWith({List<Food>? results}) => FoodSearchState(results: results ?? this.results);

  @override
  List<Object?> get props => [results];
}
