import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_settings.dart';
import 'package:vitta/app/domain/log_reminders/entities/log_reminder_tracker.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_cubit.dart';
import 'package:vitta/app/presentation/pages/log_reminders/log_reminders_presentation_event.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminder_tracker_tile.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminders_master_card.dart';
import 'package:vitta/app/presentation/pages/log_reminders/widgets/log_reminders_trackers_card.dart';

class LogRemindersPage extends StatelessWidget {
  const LogRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<LogRemindersCubit, LogReminderSettings, LogRemindersPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        LogRemindersPermissionDenied() => context.showWarningToast(
          title: l10n.logRemindersPermissionDeniedTitle,
          message: l10n.logRemindersPermissionDeniedMessage,
        ),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.logRemindersTitle)),
        body: ListView(
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            VTAppearEffect(
              child: LogRemindersMasterCard(
                isEnabled: state.isEnabled,
                onChanged: (isEnabled) => cubit.setEnabled(isEnabled: isEnabled),
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 1,
              child: LogRemindersTrackersCard(
                title: l10n.logRemindersTrackersLabel,
                children: [
                  for (final tracker in LogReminderTracker.values)
                    LogReminderTrackerTile(
                      tracker: tracker,
                      schedule: state.scheduleFor(tracker),
                      isEditable: state.isEnabled,
                      onEnabledChanged: (isEnabled) => cubit.setTrackerEnabled(tracker: tracker, isEnabled: isEnabled),
                      onTimeChanged: (time) => cubit.setTrackerTime(tracker: tracker, hour: time.hour, minute: time.minute),
                      onIntervalChanged: (intervalHours) => cubit.setTrackerInterval(tracker: tracker, intervalHours: intervalHours),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
