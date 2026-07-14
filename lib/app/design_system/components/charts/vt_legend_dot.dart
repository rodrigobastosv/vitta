import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTLegendDot extends StatelessWidget {
  const VTLegendDot({required this.label, required this.color, this.isDashed = false, super.key});

  final String label;
  final Color color;
  final bool isDashed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: .min,
    children: [
      if (isDashed)
        SizedBox(
          width: 12,
          child: Divider(color: color.withValues(alpha: 0.5), thickness: 1.5),
        )
      else
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: .circle),
        ),
      const VTGap.s(),
      Text(label, style: VTTextStyles.caption(context)),
    ],
  );
}
