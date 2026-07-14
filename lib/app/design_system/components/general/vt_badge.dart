import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTBadge extends StatelessWidget {
  const VTBadge({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.xs),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: VTRadius.borderRadiusFull),
    child: Text(
      label,
      style: VTTextStyles.caption(context).copyWith(color: color, fontWeight: .w700),
    ),
  );
}
