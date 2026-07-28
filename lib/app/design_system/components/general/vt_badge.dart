import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTBadge extends StatelessWidget {
  const VTBadge({required this.label, required this.color, this.onTap, this.tooltip, super.key});

  final String label;
  final Color color;

  // Passing no callback leaves the badge the plain figure it is everywhere else;
  // passing one turns it into the way to type that figure exactly, which is what
  // a stepped slider cannot express.
  final VoidCallback? onTap;

  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
      child: Row(
        mainAxisSize: .min,
        children: [
          Text(
            label,
            style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
          ),
          if (onTap != null) ...[
            const VTGap.xs(),
            Icon(Icons.edit_outlined, size: 12, color: color),
          ],
        ],
      ),
    );
    if (onTap case final onTap?) {
      // The pill itself is well under the 44 floor, so the tap target is the box
      // around it rather than the pill's own padding.
      return Tooltip(
        message: tooltip ?? label,
        child: InkWell(
          onTap: onTap,
          borderRadius: VTRadius.borderRadiusFull,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: VTSpacing.minTapTarget, minHeight: VTSpacing.minTapTarget),
            child: Center(widthFactor: 1, heightFactor: 1, child: pill),
          ),
        ),
      );
    }
    return pill;
  }
}
