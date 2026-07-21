import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTCalendarDayCell extends StatelessWidget {
  const VTCalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    this.valueColor,
    this.isSelected = false,
    this.allowsEmptySelection = false,
    this.onTap,
    super.key,
  });

  final DateTime day;
  final bool isToday;
  final bool isFuture;

  final Color? valueColor;

  final bool isSelected;

  final bool allowsEmptySelection;

  final VoidCallback? onTap;

  bool get _hasValue => valueColor != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return InkWell(
      // Gate on whether the day has data, not on isFuture: reminders live in the
      // future, and for the diet/water/sleep calendars a future day has no value
      // anyway, so it stays untappable there.
      onTap: (_hasValue || allowsEmptySelection) && onTap != null
          ? () {
              VTHaptics.selection();
              onTap!();
            }
          : null,
      borderRadius: VTRadius.borderRadiusM,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: .center,
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : valueColor?.withValues(alpha: 0.16),
              shape: .circle,
              border: isToday ? Border.all(color: colorScheme.primary, width: 1.5) : null,
            ),
            child: Text(
              '${day.day}',
              style: VTTextStyles.caption(context).copyWith(
                // A day with reminders keeps its accent even in the future; only
                // empty future days (the history calendars) dim.
                color: isSelected ? colorScheme.onPrimary : valueColor ?? (isFuture ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface),
                fontWeight: _hasValue ? .w700 : .w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
