import 'package:vitta/app/domain/workout/entities/body_region.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum MuscleGroup {
  abdominals,
  abductors,
  adductors,
  biceps,
  calves,
  chest,
  forearms,
  glutes,
  hamstrings,
  lats,
  lowerBack,
  middleBack,
  neck,
  quadriceps,
  shoulders,
  traps,
  triceps;

  static MuscleGroup? fromWireValue(String value) {
    for (final muscleGroup in MuscleGroup.values) {
      if (muscleGroup.wireValue == value) {
        return muscleGroup;
      }
    }
    return null;
  }

  String get wireValue => switch (this) {
    .lowerBack => 'lower_back',
    .middleBack => 'middle_back',
    _ => name,
  };

  String getLabel(AppLocalizations l10n) => switch (this) {
    .abdominals => l10n.muscleGroupAbdominals,
    .abductors => l10n.muscleGroupAbductors,
    .adductors => l10n.muscleGroupAdductors,
    .biceps => l10n.muscleGroupBiceps,
    .calves => l10n.muscleGroupCalves,
    .chest => l10n.muscleGroupChest,
    .forearms => l10n.muscleGroupForearms,
    .glutes => l10n.muscleGroupGlutes,
    .hamstrings => l10n.muscleGroupHamstrings,
    .lats => l10n.muscleGroupLats,
    .lowerBack => l10n.muscleGroupLowerBack,
    .middleBack => l10n.muscleGroupMiddleBack,
    .neck => l10n.muscleGroupNeck,
    .quadriceps => l10n.muscleGroupQuadriceps,
    .shoulders => l10n.muscleGroupShoulders,
    .traps => l10n.muscleGroupTraps,
    .triceps => l10n.muscleGroupTriceps,
  };

  BodyRegion get region => switch (this) {
    .chest => .chest,
    .lats || .middleBack || .lowerBack || .traps => .back,
    .shoulders || .neck => .shoulders,
    .biceps || .triceps || .forearms => .arms,
    .abdominals => .core,
    .quadriceps || .hamstrings || .glutes || .calves || .abductors || .adductors => .legs,
  };
}
