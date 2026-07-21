import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/paywall/widgets/paywall_plan_card.dart';

class PaywallPurchaseSection extends StatelessWidget {
  const PaywallPurchaseSection({
    required this.isSignedIn,
    required this.isOfferLoaded,
    required this.onSignUp,
    required this.onSubscribe,
    required this.onRestore,
    required this.onRetryOffer,
    this.offer,
    super.key,
  });

  final bool isSignedIn;
  final VoidCallback onSignUp;
  final VoidCallback onSubscribe;
  final VoidCallback onRestore;
  final VoidCallback onRetryOffer;

  /// Whether the store has answered at all — see PremiumState.isOfferLoaded.
  final bool isOfferLoaded;

  /// Null while the store has not answered, or when purchases are unconfigured.
  final PremiumOffer? offer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    // A subscription belongs to an account, not a device - an anonymous session
    // cannot own one and could not restore it after a reinstall.
    if (!isSignedIn) {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            l10n.premiumSignUpPrompt,
            textAlign: .center,
            style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const VTGap.m(),
          VTPrimaryButton(label: l10n.premiumSignUpAction, icon: Icons.person_add_outlined, onPressed: onSignUp),
        ],
      );
    }

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PaywallPlanCard(isLoaded: isOfferLoaded, onRetry: onRetryOffer, offer: offer),
        const VTGap.m(),
        // Disabled rather than hidden while there is nothing to buy: the CTA is
        // what the screen is for, and a button that appears late moves
        // everything under it.
        VTPrimaryButton(
          label: l10n.premiumSubscribeAction,
          icon: Icons.workspace_premium_outlined,
          onPressed: offer == null ? null : onSubscribe,
        ),
        const VTGap.s(),
        // Required by App Review, and the only way a reinstalling user gets
        // their entitlement back - so it shows even with no offer loaded.
        TextButton(onPressed: onRestore, child: Text(l10n.premiumRestoreAction)),
      ],
    );
  }
}
