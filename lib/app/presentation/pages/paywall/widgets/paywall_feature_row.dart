import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/premium/entities/premium_feature.dart';
import 'package:vitta/app/presentation/pages/paywall/premium_feature_labels.dart';

// A card rather than a bare row: the paywall's whole problem was reading as a
// feature list, and a list of rows is what a feature list looks like.
//
// The disc is solid premium with inkOn for the contrast reason PaywallHeader
// documents. The highlight is a border, never coloured text - premium as body
// text measures 3.25:1 on a light card, under AA's 4.5:1, so the old
// isHighlighted styling made the one row the user came for the hardest to read.
class PaywallFeatureRow extends StatelessWidget {
  const PaywallFeatureRow({required this.feature, this.isHighlighted = false, super.key});

  final PremiumFeature feature;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final card = VTCard(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: VTColors.premium,
            child: Icon(premiumFeatureIcon(feature), size: 22, color: VTColors.inkOn(VTColors.premium)),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(premiumFeatureTitle(l10n, feature), style: VTTextStyles.bodyStrong(context)),
                const VTGap.xs(),
                Text(
                  premiumFeatureSubtitle(l10n, feature),
                  style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!isHighlighted) {
      return card;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: VTRadius.borderRadiusL,
        border: Border.all(color: VTColors.premium, width: 2),
      ),
      child: Padding(padding: const EdgeInsets.all(VTSpacing.xs / 2), child: card),
    );
  }
}
