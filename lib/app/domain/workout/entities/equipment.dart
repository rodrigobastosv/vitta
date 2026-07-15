import 'package:flutter/material.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

enum Equipment {
  barbell,
  dumbbell,
  kettlebells,
  cable,
  machine,
  bands,
  bodyOnly,
  exerciseBall,
  medicineBall,
  foamRoll,
  ezCurlBar,
  other;

  static Equipment? fromWireValue(String value) => switch (value) {
    'barbell' => Equipment.barbell,
    'dumbbell' => Equipment.dumbbell,
    'kettlebells' => Equipment.kettlebells,
    'cable' => Equipment.cable,
    'machine' => Equipment.machine,
    'bands' => Equipment.bands,
    'body_only' => Equipment.bodyOnly,
    'exercise_ball' => Equipment.exerciseBall,
    'medicine_ball' => Equipment.medicineBall,
    'foam_roll' => Equipment.foamRoll,
    'e_z_curl_bar' => Equipment.ezCurlBar,
    'other' => Equipment.other,
    _ => null,
  };

  String get wireValue => switch (this) {
    Equipment.bodyOnly => 'body_only',
    Equipment.exerciseBall => 'exercise_ball',
    Equipment.medicineBall => 'medicine_ball',
    Equipment.foamRoll => 'foam_roll',
    Equipment.ezCurlBar => 'e_z_curl_bar',
    _ => name,
  };

  String getLabel(AppLocalizations l10n) => switch (this) {
    .barbell => l10n.equipmentBarbell,
    .dumbbell => l10n.equipmentDumbbell,
    .kettlebells => l10n.equipmentKettlebells,
    .cable => l10n.equipmentCable,
    .machine => l10n.equipmentMachine,
    .bands => l10n.equipmentBands,
    .bodyOnly => l10n.equipmentBodyOnly,
    .exerciseBall => l10n.equipmentExerciseBall,
    .medicineBall => l10n.equipmentMedicineBall,
    .foamRoll => l10n.equipmentFoamRoll,
    .ezCurlBar => l10n.equipmentEzCurlBar,
    .other => l10n.equipmentOther,
  };

  IconData get icon => switch (this) {
    .barbell || .ezCurlBar => Icons.fitness_center_outlined,
    .dumbbell => Icons.fitness_center_outlined,
    .kettlebells => Icons.sports_gymnastics_outlined,
    .cable => Icons.cable_outlined,
    .machine => Icons.precision_manufacturing_outlined,
    .bands => Icons.line_weight_outlined,
    .bodyOnly => Icons.accessibility_new_outlined,
    .exerciseBall || .medicineBall => Icons.sports_volleyball_outlined,
    .foamRoll => Icons.straighten_outlined,
    .other => Icons.category_outlined,
  };
}
