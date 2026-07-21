import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class ReminderDateSelector extends StatelessWidget {
  const ReminderDateSelector({required this.date, required this.onPreviousDay, required this.onNextDay, required this.onPickDate, super.key});

  final DateTime date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final ValueChanged<DateTime> onPickDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: l10n.reminderPreviousDayTooltip, onPressed: onPreviousDay),
        TextButton(
          onPressed: () => _pickDate(context),
          child: Text(_label(context), style: VTTextStyles.title(context)),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), tooltip: l10n.reminderNextDayTooltip, onPressed: onNextDay),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) {
      onPickDate(DateTime(picked.year, picked.month, picked.day));
    }
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    return switch (date) {
      final d when d == today => l10n.reminderToday,
      final d when d == tomorrow => l10n.reminderTomorrow,
      final d when d == yesterday => l10n.reminderYesterday,
      _ => context.materialLocalizations.formatMediumDate(date),
    };
  }
}
