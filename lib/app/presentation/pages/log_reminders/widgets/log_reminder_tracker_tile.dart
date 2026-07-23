import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_schedule.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminder_repeat_label.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminder_tracker_labels.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_sheet.dart';

class LogReminderTrackerTile extends StatelessWidget {
  const LogReminderTrackerTile({
    required this.tracker,
    required this.schedule,
    required this.isEditable,
    required this.onEnabledChanged,
    required this.onTimeChanged,
    required this.onIntervalChanged,
    super.key,
  });

  final LogReminderTracker tracker;
  final LogReminderSchedule schedule;
  final bool isEditable;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<int?> onIntervalChanged;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute));
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  Future<void> _pickInterval(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showSettingsOptionSheet<int?>(
      context,
      title: l10n.logRemindersRepeatLabel,
      selected: schedule.intervalHours,
      options: [
        SettingsOption(label: l10n.logRemindersRepeatOnce, value: null),
        for (final hours in LogReminderSchedule.intervalHourOptions) SettingsOption(label: l10n.logRemindersRepeatEveryHours(hours), value: hours),
      ],
    );
    if (picked != null) {
      onIntervalChanged(picked.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final time = TimeOfDay(hour: schedule.hour, minute: schedule.minute);
    final isTunable = isEditable && schedule.isEnabled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
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
              Switch(value: schedule.isEnabled, onChanged: isEditable ? onEnabledChanged : null),
            ],
          ),
          Wrap(
            children: [
              Tooltip(
                message: l10n.logRemindersChangeTimeTooltip,
                child: TextButton.icon(
                  onPressed: isTunable ? () => _pickTime(context) : null,
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(context.materialLocalizations.formatTimeOfDay(time)),
                ),
              ),
              if (tracker.supportsInterval)
                Tooltip(
                  message: l10n.logRemindersRepeatTooltip,
                  child: TextButton.icon(
                    onPressed: isTunable ? () => _pickInterval(context) : null,
                    icon: const Icon(Icons.repeat, size: 18),
                    label: Text(schedule.repeatLabel(l10n)),
                  ),
                ),
            ],
          ),
          if (schedule.repeatsThroughTheDay)
            Padding(
              padding: const EdgeInsets.only(left: VTSpacing.s, bottom: VTSpacing.xs),
              child: Text(
                l10n.logRemindersRepeatWindowHint(context.materialLocalizations.formatTimeOfDay(time)),
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
