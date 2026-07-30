import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/logging_streak.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_calendar_sheet.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_streak_chip.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_week_day_cell.dart';

/// The week around the day being viewed, with a dot per day coloured by how its
/// calories landed, and the logging streak beside the date.
///
/// It replaces the prev/next chevrons rather than joining them: every day in
/// reach of a chevron is now one tap away directly, and the date label still
/// opens the full calendar for anything further back. `DaySelector` is left
/// alone — water shares it and has no days to dot.
class DietWeekStrip extends StatelessWidget {
  const DietWeekStrip({
    required this.date,
    required this.macrosByDate,
    required this.macroGoals,
    required this.streak,
    required this.onPickDate,
    this.horizontalBleed = VTSpacing.m,
    super.key,
  });

  /// How much page padding the day row should widen back out over, so seven
  /// cells still clear the tap-target floor on the narrowest phone.
  final double horizontalBleed;

  final DateTime date;
  final Map<DateTime, DailyMacros> macrosByDate;
  final MacroGoals macroGoals;
  final LoggingStreak streak;
  final ValueChanged<DateTime> onPickDate;

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = context.materialLocalizations;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        // spaceBetween rather than a Spacer: a Spacer is itself a flex child, so
        // it and the Flexible date button split the free space between them and
        // the streak only travels half way to the edge.
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Flexible(
              child: TextButton.icon(
                onPressed: () => _pickDate(context),
                iconAlignment: .end,
                icon: const Icon(Icons.expand_more, size: 20),
                label: Text(_label(context, today), style: VTTextStyles.title(context), overflow: .ellipsis),
              ),
            ),
            if (streak.isActive) DietStreakChip(streak: streak),
          ],
        ),
        const VTGap.s(),
        // Seven cells inside the page's own padding measure 41px on a 320px
        // phone, under the 44 tap-target floor - the width is arithmetic, not
        // styling, so the row is widened back to the full screen instead. It
        // stays inside the viewport, so nothing is clipped.
        LayoutBuilder(
          builder: (context, constraints) => OverflowBox(
            maxWidth: constraints.maxWidth + horizontalBleed * 2,
            fit: .deferToChild,
            child: Row(
              children: [
                for (final day in _weekOf(date, materialLocalizations.firstDayOfWeekIndex))
                  Expanded(
                    child: DietWeekDayCell(
                      date: day,
                      weekdayLabel: materialLocalizations.narrowWeekdays[day.weekday % DateTime.daysPerWeek],
                      isSelected: day == date,
                      isToday: day == today,
                      dotColor: _dotColorFor(day),
                      onTap: day.isAfter(today) ? null : () => onPickDate(day),
                      tooltip: _tooltipFor(context, day),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<DateTime> _weekOf(DateTime date, int firstDayOfWeekIndex) {
    final offsetFromFirst = (date.weekday % DateTime.daysPerWeek - firstDayOfWeekIndex + DateTime.daysPerWeek) % DateTime.daysPerWeek;
    final start = DateTime(date.year, date.month, date.day - offsetFromFirst);
    return [for (var index = 0; index < DateTime.daysPerWeek; index++) DateTime(start.year, start.month, start.day + index)];
  }

  Color? _dotColorFor(DateTime day) {
    final macros = macrosByDate[day];
    return macros == null || macros.entries.isEmpty ? null : macros.adherenceTo(macroGoals).color;
  }

  String _tooltipFor(BuildContext context, DateTime day) {
    final formatted = context.materialLocalizations.formatMediumDate(day);
    final macros = macrosByDate[day];
    return macros == null || macros.entries.isEmpty
        ? context.l10n.dietWeekDayNothingTooltip(formatted)
        : context.l10n.dietWeekDayTooltip(formatted, macros.totalCalories.round());
  }

  String _label(BuildContext context, DateTime today) {
    final l10n = context.l10n;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    return switch (date) {
      final day when day == today => l10n.dayToday,
      final day when day == yesterday => l10n.dayYesterday,
      _ => context.materialLocalizations.formatMediumDate(date),
    };
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDietCalendarSheet(context: context);
    if (picked != null) {
      onPickDate(picked);
    }
  }
}
