import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension LogReminderTrackerLabel on LogReminderTracker {
  String label(AppLocalizations l10n) => switch (this) {
    .breakfast => l10n.logRemindersBreakfastLabel,
    .lunch => l10n.logRemindersLunchLabel,
    .dinner => l10n.logRemindersDinnerLabel,
    .water => l10n.logRemindersWaterLabel,
    .sleep => l10n.logRemindersSleepLabel,
  };

  IconData get icon => switch (this) {
    .breakfast => Icons.wb_sunny_outlined,
    .lunch => Icons.lunch_dining_outlined,
    .dinner => Icons.dinner_dining_outlined,
    .water => Icons.water_drop_outlined,
    .sleep => Icons.bedtime_outlined,
  };

  Color get accent => switch (this) {
    .breakfast => VTColors.macroProtein,
    .lunch => VTColors.green,
    .dinner => VTColors.macroFat,
    .water => VTColors.water,
    .sleep => VTColors.sleep,
  };
}
