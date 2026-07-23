import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension LogReminderTrackerLabel on LogReminderTracker {
  String label(AppLocalizations l10n) => switch (this) {
    .diet => l10n.logRemindersDietLabel,
    .water => l10n.logRemindersWaterLabel,
    .sleep => l10n.logRemindersSleepLabel,
  };

  IconData get icon => switch (this) {
    .diet => Icons.restaurant_outlined,
    .water => Icons.water_drop_outlined,
    .sleep => Icons.bedtime_outlined,
  };

  Color get accent => switch (this) {
    .diet => VTColors.macroCarbs,
    .water => VTColors.water,
    .sleep => VTColors.sleep,
  };
}
