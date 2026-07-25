import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';

/// How much of a food was logged: always [grams], plus - when the user did not
/// type a weight - the number they actually typed.
///
/// [grams] is the source of truth for every calorie and macro. [units] and
/// [milliliters] are *recorded*, so the day view can say "2 un" or "200 mL" back
/// instead of answering "100 g" to someone who typed "2 eggs"; they are
/// deliberately never used to recompute [grams], because a later re-run of
/// tool/populate_food_facts.dart that revises a food's unit weight or density
/// must not move yesterday's numbers.
///
/// A quantity was typed one way, so at most one of the two is set - which the
/// three named constructors make unrepresentable otherwise, and
/// `food_logs_quantity_shape` enforces in the database. This is the value object
/// the whole log path speaks, the way SetInput is for a workout set: the
/// alternative was a third `double?` parameter on the cubit, the use case, the
/// repository, the datasource and both requests.
class LoggedQuantity extends Equatable {
  const LoggedQuantity.weight(this.grams) : units = null, milliliters = null;

  const LoggedQuantity.units({required this.units, required this.grams}) : milliliters = null;

  const LoggedQuantity.volume({required this.milliliters, required this.grams}) : units = null;

  factory LoggedQuantity.fromLog(FoodLog log) => switch (log) {
    FoodLog(quantityUnits: final units?) => LoggedQuantity.units(units: units, grams: log.quantityGrams),
    FoodLog(quantityMl: final milliliters?) => LoggedQuantity.volume(milliliters: milliliters, grams: log.quantityGrams),
    _ => LoggedQuantity.weight(log.quantityGrams),
  };

  final double grams;
  final double? units;
  final double? milliliters;

  @override
  List<Object?> get props => [grams, units, milliliters];
}
