import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTCalendarDayCell extends StatelessWidget {
  const VTCalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    this.valueColor,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final DateTime day;
  final bool isToday;
  final bool isFuture;

  /// How the day scored — `null` means nothing was logged, which is what makes
  /// the cell plain and untappable. The component never derives this itself:
  /// what counts as "good" is the feature's business, not the calendar's.
  final Color? valueColor;

  final bool isSelected;

  /// Passing none disables the cell even when it has data.
  final VoidCallback? onTap;

  bool get _hasValue => valueColor != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: isFuture || !_hasValue ? null : onTap,
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
                color: isSelected
                    ? colorScheme.onPrimary
                    : isFuture
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : valueColor ?? colorScheme.onSurface,
                fontWeight: _hasValue ? .w700 : .w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
