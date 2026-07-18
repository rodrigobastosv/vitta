import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_tile.dart';

class ReminderDayPage extends StatelessWidget {
  const ReminderDayPage({required this.date, required this.reminders, super.key});

  final DateTime date;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(context.materialLocalizations.formatFullDate(date))),
      body: reminders.isEmpty
          ? VTEmptyState(icon: Icons.check_circle_outline, title: l10n.reminderEmptyTitle, message: l10n.reminderEmptyMessage)
          : ListView.separated(
              padding: const EdgeInsets.all(VTSpacing.m),
              itemCount: reminders.length,
              separatorBuilder: (_, _) => const VTGap.s(),
              itemBuilder: (context, index) => VTAppearEffect(
                key: ValueKey(reminders[index].id),
                delay: Duration(milliseconds: index * 40),
                child: ReminderTile(reminder: reminders[index]),
              ),
            ),
    );
  }
}
