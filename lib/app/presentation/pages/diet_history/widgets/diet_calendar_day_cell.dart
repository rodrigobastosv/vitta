import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/daily_macros.dart';
import 'package:vitta/app/domain/diet/entities/macro_goals.dart';

class DietCalendarDayCell extends StatelessWidget {
  const DietCalendarDayCell({
    required this.day,
    required this.dayMacros,
    required this.macroGoals,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final DateTime day;
  final DailyMacros? dayMacros;
  final MacroGoals macroGoals;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final macros = dayMacros;
    final hasLog = macros != null && macros.entries.isNotEmpty;
    final adherenceColor = hasLog ? macros.adherenceTo(macroGoals).color : null;
    return InkWell(
      onTap: isFuture || !hasLog ? null : onTap,
      borderRadius: VTRadius.borderRadiusM,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: .center,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : adherenceColor?.withValues(alpha: 0.16),
              shape: .circle,
              border: isToday ? Border.all(color: colorScheme.primary, width: 1.5) : null,
            ),
            child: Text(
              '${day.day}',
              style: VTTextStyles.caption(context).copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : isFuture
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : adherenceColor ?? colorScheme.onSurface,
                fontWeight: hasLog ? .w700 : .w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
