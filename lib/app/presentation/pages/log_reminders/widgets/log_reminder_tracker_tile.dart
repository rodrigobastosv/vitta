import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminder_tracker_labels.dart';

class LogReminderTrackerTile extends StatelessWidget {
  const LogReminderTrackerTile({
    required this.tracker,
    required this.schedule,
    required this.isEditable,
    required this.onEnabledChanged,
    required this.onTimeChanged,
    super.key,
  });

  final LogReminderTracker tracker;
  final LogReminderSchedule schedule;
  final bool isEditable;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute));
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
    final canPickTime = isEditable && schedule.isEnabled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: .center,
            decoration: BoxDecoration(color: tracker.accent, shape: .circle),
            child: Icon(tracker.icon, size: 20, color: VTColors.inkOn(tracker.accent)),
          ),
          const VTGap.s(),
          Expanded(child: Text(tracker.label(l10n), style: VTTextStyles.body(context))),
          Tooltip(
            message: l10n.logRemindersChangeTimeTooltip,
            child: TextButton(
              onPressed: canPickTime ? () => _pickTime(context) : null,
              child: Text(context.materialLocalizations.formatTimeOfDay(time)),
            ),
          ),
          Switch(value: schedule.isEnabled, onChanged: isEditable ? onEnabledChanged : null),
        ],
      ),
    );
  }
}
