import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTMonthNavigator extends StatelessWidget {
  const VTMonthNavigator({required this.month, required this.canGoToNextMonth, required this.onPreviousMonth, required this.onNextMonth, super.key});

  final DateTime month;
  final bool canGoToNextMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: .spaceBetween,
    children: [
      IconButton(icon: const Icon(Icons.chevron_left), tooltip: context.l10n.previousMonth, onPressed: onPreviousMonth),
      Text(context.materialLocalizations.formatMonthYear(month), style: VTTextStyles.title(context)),
      IconButton(icon: const Icon(Icons.chevron_right), tooltip: context.l10n.nextMonth, onPressed: canGoToNextMonth ? onNextMonth : null),
    ],
  );
}
