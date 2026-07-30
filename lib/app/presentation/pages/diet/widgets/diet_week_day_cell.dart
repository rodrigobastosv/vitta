import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class DietWeekDayCell extends StatelessWidget {
  const DietWeekDayCell({
    required this.date,
    required this.weekdayLabel,
    required this.isSelected,
    required this.isToday,
    required this.dotColor,
    required this.onTap,
    required this.tooltip,
    super.key,
  });

  static const double _circleSize = 34;
  static const double _dotSize = 6;

  final DateTime date;
  final String weekdayLabel;
  final bool isSelected;
  final bool isToday;

  // Null is a day with nothing logged, which is what leaves the dot faint - the
  // VTCalendarMonthGrid dayColor convention.
  final Color? dotColor;

  // The "pass no callback to disable" convention: a future day has nothing to
  // show and is handed none.
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isEnabled = onTap != null;
    final numberInk = switch ((isSelected, isEnabled)) {
      (true, _) => colorScheme.onPrimary,
      (false, false) => colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      (false, true) => colorScheme.onSurface,
    };
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: isEnabled
            ? () {
                VTHaptics.selection();
                onTap!();
              }
            : null,
        radius: _circleSize,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: VTSpacing.minTapTarget),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(
                weekdayLabel,
                style: VTTextStyles.overline(context).copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const VTGap.xs(),
              AnimatedContainer(
                duration: VTMotion.transition,
                curve: VTMotion.curve,
                width: _circleSize,
                height: _circleSize,
                alignment: .center,
                decoration: BoxDecoration(
                  shape: .circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  // Today keeps its ring even while selected, drawn in the ink
                  // that sits on the fill - the VTCalendarDayCell rule.
                  border: isToday ? Border.all(color: isSelected ? colorScheme.onPrimary : colorScheme.primary, width: 1.5) : null,
                ),
                child: Text(
                  '${date.day}',
                  style: VTTextStyles.body(context).copyWith(color: numberInk, fontWeight: isToday || isSelected ? .w700 : .w500),
                ),
              ),
              const VTGap.xs(),
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(shape: .circle, color: dotColor ?? colorScheme.onSurface.withValues(alpha: 0.12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
