import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// Apple's standard EULA, which applies automatically because no custom license
// agreement is configured in App Store Connect - so this is the Terms of Use the
// paywall is required to link, and there is nothing of ours to host for it.
const _termsUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const _privacyUrl = 'https://rodrigobastosv.github.io/vitta/privacy.html';

// App Review checks subscription paywalls for these three things specifically,
// and their absence is one of the most common rejections. They are static, so
// they exist before the purchase flow does - the price is the only part that has
// to come from the store.
class PaywallLegalFooter extends StatelessWidget {
  const PaywallLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return Column(
      children: [
        Text(
          l10n.premiumAutoRenewalDisclosure,
          textAlign: .center,
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const VTGap.s(),
        Row(
          mainAxisAlignment: .center,
          children: [
            TextButton(onPressed: () => _open(context, _termsUrl), child: Text(l10n.premiumTermsAction)),
            Text('·', style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant)),
            TextButton(onPressed: () => _open(context, _privacyUrl), child: Text(l10n.premiumPrivacyAction)),
          ],
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final l10n = context.l10n;
    final hasLaunched = await launchUrl(Uri.parse(url), mode: .externalApplication);
    if (!hasLaunched && context.mounted) {
      context.showErrorToast(message: l10n.premiumLinkFailed);
    }
  }
}
