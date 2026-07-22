import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
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

  static const double _diameter = 32;

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
    // Today keeps its ring even when selected, drawn in onPrimary so it reads against
    // the selected fill; otherwise the ring is primary over the plain surface.
    final borderColor = isToday ? (isSelected ? colorScheme.onPrimary : colorScheme.primary) : null;
    final textColor = isSelected
        ? colorScheme.onPrimary
        // A day with reminders keeps its accent even in the future; only empty future
        // days (the history calendars) dim.
        : valueColor ?? (isFuture ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface);
    return InkResponse(
      // Gate on whether the day has data, not on isFuture: reminders live in the
      // future, and for the diet/water/sleep calendars a future day has no value
      // anyway, so it stays untappable there.
      onTap: (_hasValue || allowsEmptySelection) && onTap != null
          ? () {
              VTHaptics.selection();
              onTap!();
            }
          : null,
      radius: 22,
      child: Center(
        child: AnimatedContainer(
          duration: VTMotion.transition,
          curve: VTMotion.curve,
          width: _diameter,
          height: _diameter,
          alignment: .center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : valueColor?.withValues(alpha: 0.16),
            shape: .circle,
            border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: VTMotion.transition,
            curve: VTMotion.curve,
            style: VTTextStyles.caption(context).copyWith(color: textColor, fontWeight: _hasValue || isToday ? .w700 : .w400),
            child: Text('${day.day}'),
          ),
        ),
      ),
    );
  }
}
