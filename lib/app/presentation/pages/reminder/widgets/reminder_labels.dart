import 'package:vitta/app/domain/reminder/entities/reminder_filter.dart';
import 'package:vitta/app/domain/reminder/entities/reminder_recurrence.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

// User-facing labels for the pure domain enums, kept out of the domain so the
// entities stay Flutter/l10n-free (the nutrientLabel/dietModalityLabel pattern).
extension ReminderRecurrenceLabel on ReminderRecurrence {
  String label(AppLocalizations l10n) => switch (this) {
    .none => l10n.reminderRepeatNever,
    .daily => l10n.reminderRepeatDaily,
    .weekly => l10n.reminderRepeatWeekly,
    .monthly => l10n.reminderRepeatMonthly,
  };
}

extension ReminderFilterLabel on ReminderFilter {
  String label(AppLocalizations l10n) => switch (this) {
    .all => l10n.reminderFilterAll,
    .completed => l10n.reminderFilterCompleted,
    .incomplete => l10n.reminderFilterActive,
  };
}
