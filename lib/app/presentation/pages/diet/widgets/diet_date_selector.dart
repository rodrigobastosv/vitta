import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_calendar_sheet.dart';

class DietDateSelector extends StatelessWidget {
  const DietDateSelector({
    required this.date,
    required this.canGoToNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onPickDate,
    super.key,
  });

  final DateTime date;
  final bool canGoToNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final ValueChanged<DateTime> onPickDate;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDietCalendarSheet(context: context);
    if (picked != null) {
      onPickDate(picked);
    }
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return switch (date) {
      final d when d == today => l10n.dietToday,
      final d when d == yesterday => l10n.dietYesterday,
      _ => context.materialLocalizations.formatMediumDate(date),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: l10n.dietPreviousDayTooltip, onPressed: onPreviousDay),
        TextButton(
          onPressed: () => _pickDate(context),
          child: Text(_label(context), style: VTTextStyles.title(context)),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.dietNextDayTooltip,
          onPressed: canGoToNextDay ? onNextDay : null,
        ),
      ],
    );
  }
}
