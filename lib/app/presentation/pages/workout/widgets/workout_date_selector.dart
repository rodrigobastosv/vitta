import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class WorkoutDateSelector extends StatelessWidget {
  const WorkoutDateSelector({
    required this.date,
    required this.canGoToNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    super.key,
  });

  final DateTime date;
  final bool canGoToNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: l10n.workoutPreviousDayTooltip, onPressed: onPreviousDay),
        Text(_label(context), style: VTTextStyles.title(context)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.workoutNextDayTooltip,
          onPressed: canGoToNextDay ? onNextDay : null,
        ),
      ],
    );
  }

  String _label(BuildContext context) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return context.l10n.workoutTodayTitle;
    }
    return context.materialLocalizations.formatMediumDate(date);
  }
}
