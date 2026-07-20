import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/premium/entities/premium_feature.dart';
import 'package:vitta/app/presentation/pages/premium/premium_feature_labels.dart';

class PaywallFeatureRow extends StatelessWidget {
  const PaywallFeatureRow({required this.feature, this.isHighlighted = false, super.key});

  final PremiumFeature feature;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Row(
      crossAxisAlignment: .start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: VTColors.premium.withValues(alpha: 0.16),
          child: Icon(premiumFeatureIcon(feature), size: 22, color: VTColors.premium),
        ),
        const VTGap.m(),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                premiumFeatureTitle(l10n, feature),
                style: VTTextStyles.bodyStrong(context).copyWith(color: isHighlighted ? VTColors.premium : null),
              ),
              const VTGap.xs(),
              Text(
                premiumFeatureSubtitle(l10n, feature),
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
