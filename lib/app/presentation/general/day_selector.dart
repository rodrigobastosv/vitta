import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// The prev / day / next strip a feature page uses to move between days, shared
/// by diet and water. It owns the chrome and the label — including reading
/// "Today" and "Yesterday" rather than a date nobody has to decode — and leaves
/// *how a day is picked* to the caller, since the two features answer that
/// differently: diet opens a calendar dotted with the days that have logs, water
/// has nothing to dot and opens the platform picker.
///
/// It lives in `presentation/general/` rather than the design system because the
/// today/yesterday wording is l10n, and duplicating that per feature is exactly
/// how the two would drift apart.
class DaySelector extends StatelessWidget {
  const DaySelector({
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
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: l10n.previousDayTooltip, onPressed: onPreviousDay),
        TextButton(
          onPressed: onPickDate,
          child: Text(_label(context), style: VTTextStyles.title(context)),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), tooltip: l10n.nextDayTooltip, onPressed: canGoToNextDay ? onNextDay : null),
      ],
    );
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return switch (date) {
      final day when day == today => l10n.dayToday,
      final day when day == yesterday => l10n.dayYesterday,
      _ => context.materialLocalizations.formatMediumDate(date),
    };
  }
}
