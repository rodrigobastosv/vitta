import 'package:vitta/app/domain/diet/entities/fitness_objective.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

String fitnessObjectiveLabel(AppLocalizations l10n, FitnessObjective objective) => switch (objective) {
  .loseWeight => l10n.onboardingObjectiveLoseWeight,
  .maintainWeight => l10n.onboardingObjectiveMaintainWeight,
  .gainMuscle => l10n.onboardingObjectiveGainMuscle,
};

String fitnessObjectiveMessage(AppLocalizations l10n, FitnessObjective objective) => switch (objective) {
  .loseWeight => l10n.onboardingObjectiveLoseWeightMessage,
  .maintainWeight => l10n.onboardingObjectiveMaintainWeightMessage,
  .gainMuscle => l10n.onboardingObjectiveGainMuscleMessage,
};
