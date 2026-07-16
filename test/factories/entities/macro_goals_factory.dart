import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

abstract class MacroGoalsFactory {
  static MacroGoals build({
    double proteinGoalGrams = 150,
    double carbsGoalGrams = 250,
    double fatGoalGrams = 65,
    double fiberGoalGrams = 30,
  }) => MacroGoals(
    proteinGoalGrams: proteinGoalGrams,
    carbsGoalGrams: carbsGoalGrams,
    fatGoalGrams: fatGoalGrams,
    fiberGoalGrams: fiberGoalGrams,
  );
}
