import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class HomeSupportingRow extends StatelessWidget {
  const HomeSupportingRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: VTRadius.borderRadiusM,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VTSpacing.s, vertical: VTSpacing.s),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: .center,
              decoration: BoxDecoration(color: accent, shape: .circle),
              child: Icon(icon, size: 20, color: VTColors.inkOn(accent)),
            ),
            const VTGap.s(),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                children: [
                  Text(title, style: VTTextStyles.bodyStrong(context), maxLines: 1, overflow: .ellipsis),
                  Text(
                    subtitle,
                    style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
            const VTGap.s(),
            Text(value, style: VTTextStyles.bodyStrong(context)),
          ],
        ),
      ),
    );
  }
}
