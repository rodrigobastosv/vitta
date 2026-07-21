import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class OnboardingState extends Equatable {
  const OnboardingState({this.step = 0, this.calorieGoal = _defaultCalorieGoal, this.goalsAccepted = false});

  static const int stepCount = 4;
  static const double _defaultCalorieGoal = 2000;

  final int step;
  final double calorieGoal;
  final bool goalsAccepted;

  bool get isLastStep => step == stepCount - 1;

  MacroGoals get goals => MacroGoals.defaultGoals.withScaledCalories(calorieGoal);

  OnboardingState copyWith({int? step, double? calorieGoal, bool? goalsAccepted}) =>
      OnboardingState(step: step ?? this.step, calorieGoal: calorieGoal ?? this.calorieGoal, goalsAccepted: goalsAccepted ?? this.goalsAccepted);

  @override
  List<Object?> get props => [step, calorieGoal, goalsAccepted];
}
