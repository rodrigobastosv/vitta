import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class OnboardingFeatureRow extends StatelessWidget {
  const OnboardingFeatureRow({required this.icon, required this.accent, required this.title, required this.subtitle, super.key});

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(VTSpacing.s),
          decoration: BoxDecoration(color: accent, borderRadius: VTRadius.borderRadiusM),
          child: Icon(icon, color: VTColors.inkOn(accent)),
        ),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(title, style: VTTextStyles.bodyStrong(context)),
              Text(subtitle, style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
