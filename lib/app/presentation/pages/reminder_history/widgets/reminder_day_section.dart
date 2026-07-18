import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_tile.dart';

// The reminders of the day selected in the history calendar, shown read-only
// under the calendar (ReminderTile with no callbacks is non-interactive).
class ReminderDaySection extends StatelessWidget {
  const ReminderDaySection({required this.date, required this.reminders, super.key});

  final DateTime date;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(context.materialLocalizations.formatFullDate(date), style: VTTextStyles.title(context)),
        const VTGap.s(),
        if (reminders.isEmpty)
          Text(l10n.reminderEmptyTitle, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant))
        else
          for (final reminder in reminders) ...[
            ReminderTile(reminder: reminder),
            const VTGap.s(),
          ],
      ],
    );
  }
}
