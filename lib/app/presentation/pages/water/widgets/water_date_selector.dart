import 'package:flutter/material.dart';
import 'package:vitta/app/presentation/general/day_selector.dart';

/// Water's day strip. Unlike diet's it opens the platform date picker rather
/// than a calendar sheet: there is nothing to dot — a day either has glasses on
/// it or it does not, and that is already what the page below is showing.
///
/// `lastDate` is today, so a day you cannot have drunk on is not offerable —
/// the same rule the next-day chevron enforces.
class WaterDateSelector extends StatelessWidget {
  const WaterDateSelector({
    required this.date,
    required this.canGoToNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onPickDate,
    super.key,
  });

  static const _earliestYear = 2020;

  final DateTime date;
  final bool canGoToNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final ValueChanged<DateTime> onPickDate;

  @override
  Widget build(BuildContext context) => DaySelector(
    date: date,
    canGoToNextDay: canGoToNextDay,
    onPreviousDay: onPreviousDay,
    onNextDay: onNextDay,
    onPickDate: () => _pickDate(context),
  );

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(_earliestYear),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      onPickDate(picked);
    }
  }
}
