import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/paywall/premium_period_labels.dart';

// Where the price lives, and the reason the button no longer names one: at
// 320px in pt, "Assine por R$ 14,90/mês" does not fit a button, and App Review
// only requires the price and period be *shown*, not that they be on the CTA.
//
// Three states, and they are three because a null offer alone could not tell
// them apart - see PremiumState.isOfferLoaded:
//   not asked yet -> skeleton
//   asked, nothing to sell -> the unavailable line with a retry
//   asked, got a plan -> the price
class PaywallPlanCard extends StatelessWidget {
  const PaywallPlanCard({required this.isLoaded, required this.onRetry, this.offer, super.key});

  final bool isLoaded;
  final VoidCallback onRetry;
  final PremiumOffer? offer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    if (!isLoaded) {
      return const VTCard(child: Column(children: [VTSkeleton(height: 34, width: 140), VTGap.s(), VTSkeleton(height: 14, width: 90)]));
    }

    final currentOffer = offer;
    if (currentOffer == null) {
      return VTCard(
        child: Column(
          children: [
            Text(
              l10n.premiumUnavailable,
              textAlign: .center,
              style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const VTGap.s(),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l10n.premiumOfferRetryAction)),
          ],
        ),
      );
    }

    final period = currentOffer.period;
    return VTCard(
      child: Column(
        children: [
          Text(
            currentOffer.priceLabel,
            textAlign: .center,
            style: VTTextStyles.display(context).copyWith(color: VTColors.premium),
          ),
          if (period != null) ...[
            const VTGap.xs(),
            Text(
              premiumPeriodLabel(l10n, period),
              textAlign: .center,
              style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
          const VTGap.s(),
          Text(
            l10n.premiumCancelAnytime,
            textAlign: .center,
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
