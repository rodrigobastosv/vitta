import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTFeatureTile extends StatelessWidget {
  const VTFeatureTile({required this.icon, required this.title, required this.subtitle, required this.onTap, super.key});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: VTRadius.borderRadiusL,
      child: InkWell(
        onTap: onTap,
        borderRadius: VTRadius.borderRadiusL,
        child: Padding(
          padding: const EdgeInsets.all(VTSpacing.l),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: .center,
                decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: .circle),
                child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 26),
              ),
              const VTGap.l(),
              Text(title, style: VTTextStyles.title(context)),
              const VTGap.xs(),
              Text(
                subtitle,
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: .ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
