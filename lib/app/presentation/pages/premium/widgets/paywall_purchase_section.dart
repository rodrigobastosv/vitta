import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class PaywallPurchaseSection extends StatelessWidget {
  const PaywallPurchaseSection({
    required this.isSignedIn,
    required this.onSignUp,
    required this.onSubscribe,
    required this.onRestore,
    this.offer,
    super.key,
  });

  final bool isSignedIn;
  final VoidCallback onSignUp;
  final VoidCallback onSubscribe;
  final VoidCallback onRestore;

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

    final currentOffer = offer;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        // The price is the store's own localized string, so the button cannot
        // name a figure until the store has produced one.
        if (currentOffer == null)
          Text(
            l10n.premiumUnavailable,
            textAlign: .center,
            style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          )
        else
          VTPrimaryButton(
            label: l10n.premiumSubscribeAction(currentOffer.priceLabel),
            icon: Icons.workspace_premium_outlined,
            onPressed: onSubscribe,
          ),
        const VTGap.s(),
        // Required by App Review, and the only way a reinstalling user gets
        // their entitlement back - so it shows even with no offer loaded.
        TextButton(onPressed: onRestore, child: Text(l10n.premiumRestoreAction)),
      ],
    );
  }
}
