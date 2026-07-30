import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/goals/goal_adherence.dart';
import 'package:vitta/app/domain/diet/entities/macro_nutrient.dart';
import 'package:vitta/app/domain/diet/entities/nutrient_verdict.dart';

class NutrientScore extends Equatable {
  const NutrientScore({required this.nutrient, required this.consumed, required this.goal});

  // How far past the goal band a nutrient has to land before it scores nothing
  // at all. Half the goal again either way: a day at half its protein target has
  // genuinely missed it, while 15% over is a miss worth only a few points.
  static const _bandFalloff = 0.5;

  final MacroNutrient nutrient;
  final double consumed;
  final double goal;

  // A nutrient with no goal is left out of the score rather than scored as if it
  // were met - awarding full marks for a target nobody set would flatter the day.
  bool get isScorable => goal > 0;

  double get ratio => goal > 0 ? consumed / goal : 0;

  NutrientVerdict get verdict => NutrientVerdict.forRatio(ratio);

  double get fraction {
    if (!isScorable) {
      return 0;
    }
    final overshoot = switch (ratio) {
      final ratio when ratio < GoalAdherence.metLowerBound => GoalAdherence.metLowerBound - ratio,
      final ratio when ratio > GoalAdherence.metUpperBound => ratio - GoalAdherence.metUpperBound,
      _ => 0.0,
    };
    return (1 - overshoot / _bandFalloff).clamp(0, 1);
  }

  @override
  List<Object?> get props => [nutrient, consumed, goal];
}
