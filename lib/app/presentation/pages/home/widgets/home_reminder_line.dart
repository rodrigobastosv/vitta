import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_check_circle.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/reminder/entities/reminder.dart';

class HomeReminderLine extends StatelessWidget {
  const HomeReminderLine({required this.reminder, this.onComplete, super.key});

  final Reminder reminder;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isOverdue = reminder.isOverdue();
    return Row(
      children: [
        VTCheckCircle(value: reminder.isCompleted, onChanged: onComplete == null ? null : (_) => onComplete!()),
        const VTGap.s(),
        Expanded(child: Text(reminder.title, style: VTTextStyles.body(context), maxLines: 1, overflow: .ellipsis)),
        if (reminder.remindAt case final remindAt?) ...[
          const VTGap.s(),
          Text(
            context.materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(remindAt)),
            style: VTTextStyles.caption(context).copyWith(color: isOverdue ? VTColors.error : colorScheme.onSurfaceVariant, fontWeight: .w600),
          ),
        ],
      ],
    );
  }
}
