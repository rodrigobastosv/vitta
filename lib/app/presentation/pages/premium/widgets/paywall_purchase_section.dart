import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// The purchase flow itself is a follow-up (no store products exist yet), so the
// CTA says so rather than being a button that does nothing when tapped.
class PaywallPurchaseSection extends StatelessWidget {
  const PaywallPurchaseSection({required this.isSignedIn, required this.onSignUp, super.key});

  final bool isSignedIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
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
        VTPrimaryButton(label: l10n.premiumComingSoonAction, icon: Icons.workspace_premium_outlined, onPressed: null),
        const VTGap.s(),
        Text(
          l10n.premiumComingSoonHint,
          textAlign: .center,
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
