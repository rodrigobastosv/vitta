import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_badge.dart';
import 'package:vitta/app/design_system/components/general/vt_celebration.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';
import 'package:vitta/app/presentation/pages/reminder/widgets/reminder_labels.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({required this.reminder, this.onToggle, this.onTap, this.onDelete, super.key});

  final Reminder reminder;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  void _onChanged(bool? value) {
    final completed = value ?? false;
    if (!completed) {
      VTHaptics.selection();
    }
    onToggle!(completed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final completed = reminder.isCompleted;
    return VTCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      child: Row(
        children: [
          VTCelebration(
            trigger: completed,
            size: VTCelebrationSize.small,
            child: Checkbox(value: completed, shape: const CircleBorder(), onChanged: onToggle == null ? null : _onChanged),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  reminder.title,
                  style: VTTextStyles.bodyStrong(context).copyWith(
                    decoration: completed ? TextDecoration.lineThrough : null,
                    color: completed ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
                if (_meta(context) case final meta when meta.isNotEmpty) ...[
                  const VTGap.xs(),
                  Wrap(spacing: VTSpacing.s, runSpacing: VTSpacing.xs, children: meta),
                ],
              ],
            ),
          ),
          if (onDelete case final onDelete?)
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: l10n.reminderDeleteTooltip, color: colorScheme.onSurfaceVariant, onPressed: onDelete),
        ],
      ),
    );
  }

  List<Widget> _meta(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return [
      if (reminder.remindAt case final remindAt?)
        Row(
          mainAxisSize: .min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 14, color: colorScheme.onSurfaceVariant),
            const VTGap.xs(),
            Text(context.materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(remindAt)), style: VTTextStyles.caption(context)),
          ],
        ),
      if (reminder.recurrence != .none) VTBadge(label: reminder.recurrence.label(l10n), color: VTColors.macroFat),
    ];
  }
}
