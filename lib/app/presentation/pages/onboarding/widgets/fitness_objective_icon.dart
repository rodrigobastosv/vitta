import 'package:flutter/material.dart';
import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';

// Presentation-only, like fitnessObjectiveLabel, so the domain enum stays
// Flutter-free: a falling trend for a cut, a level one for maintenance, an arm
// for the muscle being built.
IconData fitnessObjectiveIcon(FitnessObjective objective) => switch (objective) {
  .loseWeight => Icons.trending_down,
  .maintainWeight => Icons.trending_flat,
  .gainMuscle => Icons.fitness_center,
};
