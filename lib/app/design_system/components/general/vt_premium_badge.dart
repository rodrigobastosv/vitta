import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTPremiumBadge extends StatelessWidget {
  const VTPremiumBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
    decoration: BoxDecoration(color: VTColors.premium.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
    child: Row(
      mainAxisSize: .min,
      children: [
        const Icon(Icons.lock_outline, size: 12, color: VTColors.premium),
        const VTGap.xs(),
        Text(
          label,
          style: VTTextStyles.caption(context).copyWith(color: VTColors.premium, fontWeight: .w700),
        ),
      ],
    ),
  );
}
