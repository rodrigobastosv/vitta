import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_reminder_line.dart';

// Reminders are a list, not a metric, so the hero shows the day's open items
// rather than a ring against a goal.
class HomeRemindersHero extends StatelessWidget {
  const HomeRemindersHero({required this.openReminders, required this.onTap, required this.onComplete, super.key});

  static const _visibleReminders = 3;

  final List<Reminder> openReminders;
  final VoidCallback onTap;
  final ValueChanged<Reminder> onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final visible = openReminders.take(_visibleReminders).toList();
    final remaining = openReminders.length - visible.length;
    return VTCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: .center,
                decoration: const BoxDecoration(color: VTColors.coral, shape: .circle),
                child: Icon(Icons.checklist_rounded, color: VTColors.inkOn(VTColors.coral), size: 22),
              ),
              const VTGap.m(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(l10n.reminderFeatureTitle, style: VTTextStyles.overline(context)),
                    Text(l10n.homeRemindersOpen(openReminders.length), style: VTTextStyles.title(context)),
                  ],
                ),
              ),
            ],
          ),
          if (visible.isEmpty) ...[
            const VTGap.s(),
            Text(l10n.homeNoReminders, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          ],
          for (final reminder in visible) ...[
            const VTGap.xs(),
            HomeReminderLine(reminder: reminder, onComplete: () => onComplete(reminder)),
          ],
          if (remaining > 0) ...[
            const VTGap.s(),
            Text(l10n.homeRemindersMore(remaining), style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
