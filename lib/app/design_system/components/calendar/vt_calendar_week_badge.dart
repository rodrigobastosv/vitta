import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// The figure at the end of a calendar week row. A dash when the week has no
/// data at all, which is the honest answer for a week nothing was logged.
class VTCalendarWeekBadge extends StatelessWidget {
  const VTCalendarWeekBadge({this.label, this.color, this.tooltip, super.key});

  static const double width = 44;

  final String? label;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final text = label;
    final tooltipMessage = tooltip;
    if (text == null) {
      return SizedBox(
        width: width,
        child: Center(child: Text('-', style: VTTextStyles.overline(context))),
      );
    }
    final badgeColor = color ?? context.colorScheme.primary;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.xs, vertical: 2),
      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
      child: Text(
        text,
        textAlign: .center,
        style: VTTextStyles.overline(context).copyWith(color: badgeColor, fontWeight: .w700),
      ),
    );
    return SizedBox(width: width, child: tooltipMessage == null ? badge : Tooltip(message: tooltipMessage, child: badge));
  }
}
