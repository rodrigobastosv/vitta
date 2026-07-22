import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

// The floating value bubble a chart shows when a bar or point is tapped. Uses the
// inverseSurface/onInverseSurface pair (the same guaranteed-contrast combination
// Material tooltips use) so it clears WCAG against any chart colour underneath it
// without needing an entry in the accent-avatar contrast table.
class VTChartTooltip extends StatelessWidget {
  const VTChartTooltip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: colorScheme.inverseSurface,
      elevation: 3,
      borderRadius: VTRadius.borderRadiusM,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
        child: Text(
          label,
          textAlign: .center,
          style: TextStyle(color: colorScheme.onInverseSurface, fontSize: 12, fontWeight: .w600, height: 1.2),
        ),
      ),
    );
  }
}

// Positions a chart tooltip centred over the tapped mark and just above it, clamped so
// the bubble never spills outside the chart. It runs after the child is laid out, so it
// can use the bubble's real size to clamp without the caller guessing a width.
class VTChartTooltipLayout extends SingleChildLayoutDelegate {
  VTChartTooltipLayout({required this.anchor});

  final Offset anchor;

  static const double _gap = VTSpacing.xs;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (anchor.dx - childSize.width / 2).clamp(0.0, math.max(0.0, size.width - childSize.width)).toDouble();
    final top = (anchor.dy - childSize.height - _gap).clamp(0.0, math.max(0.0, size.height - childSize.height)).toDouble();
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(VTChartTooltipLayout oldDelegate) => oldDelegate.anchor != anchor;
}
