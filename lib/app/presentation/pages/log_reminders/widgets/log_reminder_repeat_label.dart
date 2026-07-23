import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

extension LogReminderRepeatLabel on LogReminderSchedule {
  String repeatLabel(AppLocalizations l10n) => switch (intervalHours) {
    final hours? => l10n.logRemindersRepeatEveryHours(hours),
    null => l10n.logRemindersRepeatOnce,
  };
}
