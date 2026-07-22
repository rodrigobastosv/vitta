import 'package:flutter/material.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension ProgressPhotoPoseLabel on ProgressPhotoPose {
  String label(AppLocalizations l10n) => switch (this) {
    .front => l10n.progressPhotosPoseFront,
    .side => l10n.progressPhotosPoseSide,
    .back => l10n.progressPhotosPoseBack,
    .other => l10n.progressPhotosPoseOther,
  };

  IconData get icon => switch (this) {
    .front => Icons.accessibility_new_outlined,
    .side => Icons.airline_seat_recline_normal_outlined,
    .back => Icons.rotate_90_degrees_ccw_outlined,
    .other => Icons.photo_camera_outlined,
  };
}
